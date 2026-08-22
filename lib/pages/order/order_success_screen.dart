import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../providers/payment_provider.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String sessionToken;

  const OrderSuccessScreen({super.key, required this.sessionToken});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  static const Color _primaryColor = Color.fromRGBO(111, 10, 15, 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentProvider>(context, listen: false).fetchOrderSummary();
    });
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return 'N/A';
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(),
      ),
      (route) => false,
    );
  }

  void _goToOrders() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(initialIndex: 2),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: paymentProvider.isLoading && paymentProvider.orderSummary == null
          ? const Center(
              child: CircularProgressIndicator(color: _primaryColor),
            )
          : paymentProvider.orderSummary != null
              ? _buildSuccessContent(paymentProvider)
              : _buildSuccessWithoutSummary(paymentProvider),
    );
  }

  /// Shown when order summary loaded successfully.
  Widget _buildSuccessContent(PaymentProvider provider) {
    final summary = provider.orderSummary!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order has been placed successfully.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                      'Order Number', '#${summary.orderNumber}'),
                  const Divider(height: 24),
                  _buildSummaryRow('Amount Paid',
                      '₹${summary.amountPaid.toStringAsFixed(2)}'),
                  const Divider(height: 24),
                  _buildSummaryRow('Payment Method', summary.paymentMethod),
                  const Divider(height: 24),
                  _buildSummaryRow(
                      'Order Date', _formatDate(summary.orderDate)),
                ],
              ),
            ),
            const Spacer(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  /// Shown when order was successful but summary API failed.
  Widget _buildSuccessWithoutSummary(PaymentProvider provider) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Order Placed Successfully!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 12),
            Text(
              'Your payment was received and your order is being processed.',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.orange[700], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Order details will be available in your Orders section shortly.',
                      style: TextStyle(
                          color: Colors.orange[800], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _goHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Continue Shopping',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: _goToOrders,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _primaryColor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'View My Orders',
              style: TextStyle(
                  fontSize: 16,
                  color: _primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
