import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment/payment_models.dart';
import '../../providers/payment_provider.dart';
import 'payment_webview_screen.dart';

class PaymentOptionsScreen extends StatefulWidget {
  final String sessionToken;

  const PaymentOptionsScreen({super.key, required this.sessionToken});

  @override
  State<PaymentOptionsScreen> createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  String? _selectedMethodId;
  static const Color _primaryColor = Color.fromRGBO(111, 10, 15, 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentProvider>(context, listen: false).fetchPaymentOptions();
    });
  }

  Future<void> _startPaymentFlow(PaymentMethodOption method) async {
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    final initiateResponse =
        await paymentProvider.initiatePayment(method.id);

    if (!mounted) return;

    if (initiateResponse != null && initiateResponse.success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            sessionToken: widget.sessionToken,
            initiateData: initiateResponse,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            paymentProvider.errorMessage ??
                'Could not start payment. Please try again.',
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text(
          'Select Payment Method',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
        backgroundColor: _primaryColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: paymentProvider.isLoading &&
              paymentProvider.paymentOptions == null
          ? const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            )
          : paymentProvider.errorMessage != null &&
                  paymentProvider.paymentOptions == null
              ? _buildErrorState(paymentProvider)
              : Consumer<PaymentProvider>(
                  builder: (context, provider, child) {
                    final options = provider.paymentOptions;
                    if (options == null || options.methods.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildPaymentContent(provider, options);
                  },
                ),
    );
  }

  Widget _buildErrorState(PaymentProvider paymentProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded,
                  size: 52, color: Colors.red[400]),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to Load Payment Methods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              paymentProvider.errorMessage ??
                  'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => paymentProvider.fetchPaymentOptions(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Try Again',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No payment methods available at the moment.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentContent(
      PaymentProvider provider, PaymentOptionsResponse options) {
    final summary = options.summary;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Payment Methods',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...options.methods.map((method) {
                final isSelected = _selectedMethodId == method.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? _primaryColor
                          : Colors.grey[200]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: _buildMethodIcon(method.type),
                    title: Text(
                      method.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: method.description != null
                        ? Text(method.description!)
                        : null,
                    trailing: Radio<String>(
                      value: method.id,
                      groupValue: _selectedMethodId,
                      activeColor: _primaryColor,
                      onChanged: (val) {
                        setState(() => _selectedMethodId = val);
                      },
                    ),
                    onTap: () {
                      setState(() => _selectedMethodId = method.id);
                    },
                  ),
                );
              }),
              const SizedBox(height: 20),
              const Text(
                'Price Details',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPriceRow(
                        'Subtotal',
                        '₹${summary.subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                        'Discount',
                        '-₹${summary.discount.toStringAsFixed(2)}',
                        valueColor: Colors.green),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildPriceRow(
                      'Grand Total',
                      '₹${summary.total.toStringAsFixed(2)}',
                      isBold: true,
                      fontSize: 18,
                    ),
                    if (summary.savings > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                summary.offerLabel ??
                                    'You saved ₹${summary.savings.toStringAsFixed(2)} on this order!',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, spreadRadius: 1),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    _selectedMethodId == null || provider.isLoading
                        ? null
                        : () {
                            final method = options.methods.firstWhere(
                                (m) => m.id == _selectedMethodId);
                            _startPaymentFlow(method);
                          },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: provider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Proceed to Pay',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodIcon(String type) {
    IconData iconData = Icons.payment;
    Color color = Colors.grey;

    switch (type.toLowerCase()) {
      case 'upi':
        iconData = Icons.account_balance_wallet;
        color = Colors.purple;
        break;
      case 'card':
        iconData = Icons.credit_card;
        color = Colors.blue;
        break;
      case 'wallet':
        iconData = Icons.wallet;
        color = Colors.orange;
        break;
      case 'netbanking':
        iconData = Icons.account_balance;
        color = Colors.teal;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isBold = false,
      double fontSize = 14,
      Color? valueColor}) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: Colors.grey[800],
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: style.copyWith(
            color: valueColor ??
                (isBold ? _primaryColor : Colors.grey[850]),
          ),
        ),
      ],
    );
  }
}
