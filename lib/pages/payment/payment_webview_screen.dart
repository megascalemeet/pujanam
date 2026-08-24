import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../providers/payment_provider.dart';
import '../../providers/cart/cart_provider.dart';
import '../../providers/orders/order_provider.dart';
import '../../models/payment/payment_models.dart';
import '../order/order_success_screen.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String sessionToken;
  final PaymentInitiateResponse initiateData;

  const PaymentWebViewScreen({
    super.key,
    required this.sessionToken,
    required this.initiateData,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  // Guard to ensure verifyPayment is only called ONCE per payment attempt
  bool _verificationTriggered = false;

  static const Color _primaryColor = Color.fromRGBO(111, 10, 15, 1);

  @override
  void initState() {
    super.initState();
    final redirectUrl = widget.initiateData.easebuzz?.redirectUrl ?? '';
    debugPrint('========== WEBVIEW INITIALIZE ==========');
    debugPrint('Redirect URL: $redirectUrl');
    debugPrint('=========================================');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView loading progress: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('WebView Page Started: $url');
            if (mounted) {
              setState(() => _isLoading = true);
            }
            // Only check for completion on page start to avoid duplicate triggers
          },
          onPageFinished: (String url) {
            debugPrint('WebView Page Finished: $url');
            if (mounted) {
              setState(() => _isLoading = false);
            }
            _checkPaymentCompletion(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('WebView Navigation Request to: ${request.url}');
            _checkPaymentCompletion(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(redirectUrl));
  }

  /// Determines if the given URL signals the end of the payment gateway flow.
  /// Uses specific response URL patterns — NOT generic store domain hits.
  void _checkPaymentCompletion(String url) {
    // If already triggered, do nothing — prevents multiple verification calls
    if (_verificationTriggered) return;

    final lowerUrl = url.toLowerCase();

    // Specific patterns that indicate the payment gateway has returned a response
    final bool isPaymentResponseUrl =
        lowerUrl.contains('easebuzz.in/pay/response') ||
        lowerUrl.contains('/payment/response') ||
        lowerUrl.contains('/checkout/response') ||
        lowerUrl.contains('/payment-status') ||
        lowerUrl.contains('/payment/success') ||
        lowerUrl.contains('/payment/failure') ||
        lowerUrl.contains('/checkout/done') ||
        lowerUrl.contains('txnstatus=') ||
        (lowerUrl.contains('status=') &&
            (lowerUrl.contains('success') ||
                lowerUrl.contains('failure') ||
                lowerUrl.contains('fail') ||
                lowerUrl.contains('cancel')));

    if (!isPaymentResponseUrl) return;

    // Determine final payment status from URL
    String status = 'success';
    if (lowerUrl.contains('fail') ||
        lowerUrl.contains('cancel') ||
        lowerUrl.contains('status=failure') ||
        lowerUrl.contains('status=failed') ||
        lowerUrl.contains('txnstatus=failure') ||
        lowerUrl.contains('txnstatus=failed')) {
      status = 'failure';
    }

    debugPrint('Payment response URL detected. Status: $status');
    _verificationTriggered = true;
    _verifyPayment(status);
  }

  Future<void> _verifyPayment(String status) async {
    if (!mounted) return;

    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider =
        Provider.of<OrderProvider>(context, listen: false);

    final txnid = widget.initiateData.easebuzz?.txnid ?? '';
    final easepayid = widget.initiateData.paymentId;
    final hash = widget.initiateData.easebuzz?.accessKey ?? '';

    final verifyData = {
      'txnid': txnid,
      'easepayid': easepayid,
      'hash': hash,
      'status': status,
    };

    debugPrint('========== VERIFY PAYMENT REQUEST ==========');
    debugPrint('Payload: $verifyData');

    final result = await paymentProvider.verifyPayment(verifyData);

    debugPrint('========== VERIFY PAYMENT RESPONSE ==========');
    debugPrint('Success: ${result?.success}');
    debugPrint('Status arg: $status');
    debugPrint('=============================================');

    if (!mounted) return;

    if (result != null && result.success) {
      // Clear cart and refresh orders
      await cartProvider.clearCart();
      try {
        await orderProvider.fetchOrders();
      } catch (_) {
        // Non-critical — order list refresh can fail silently
      }

      if (!mounted) return;

      // Keep the home route in the stack so Back works from success screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OrderSuccessScreen(sessionToken: widget.sessionToken),
        ),
        (route) => route.isFirst,
      );
    } else {
      // Reset flag so user can retry if they choose the retry option
      _verificationTriggered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          if (mounted) Navigator.of(context).pop();
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Complete Payment',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: _primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: _primaryColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
