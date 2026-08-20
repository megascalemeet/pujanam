import 'package:flutter/material.dart';
import 'package:pujanam/theme/app_color.dart';
import 'package:pujanam/widgets/whastapp.dart';
import 'package:url_launcher/url_launcher.dart';

class ReturnPolicyScreen extends StatelessWidget {
  const ReturnPolicyScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri uri = Uri.parse('mailto:shrinilkanthstore@gmail.com');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $uri');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  Future<void> _launchPhone() async {
    final Uri uri = Uri.parse('tel:+918238811190');
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $uri');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color brandColor = AppColors.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: brandColor,
        title: const Text(
          'Return Policy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: brandColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Effective Date: June 1, 2025',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'At Nilkanth Store Trade Name : ILAVIZ, we value our customers and aim to ensure your satisfaction with every purchase.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.6,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'If for any reason you are not completely satisfied with your purchase, we offer a straightforward return policy to make the process as simple as possible.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  _buildSection(
                    title: 'Eligibility for Returns',
                    icon: Icons.check_circle_outline,
                    brandColor: brandColor,
                    children: [
                      _buildBulletPoint(
                        'The item must be in its original packaging.',
                      ),
                      _buildBulletPoint(
                        'The item must be unused and in the same condition as received.',
                      ),
                      _buildBulletPoint(
                        'You must initiate the return process within 1 day from the date of delivery.',
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Non-Returnable Items',
                    icon: Icons.not_interested_outlined,
                    brandColor: brandColor,
                    children: [
                      _buildBulletPoint(
                        'Items marked as final sale or clearance.',
                      ),
                      _buildBulletPoint('Customized or personalized items.'),
                      _buildBulletPoint(
                        'Items damaged due to misuse, accidents, or neglect.',
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Return Process',
                    icon: Icons.replay_rounded,
                    brandColor: brandColor,
                    children: [
                      _buildNumberedPoint(
                        1,
                        'Contact our customer support team at shrinilkanthstore@gmail.com.',
                      ),
                      _buildNumberedPoint(
                        2,
                        'Provide your order number, details of the item(s), and reason for return.',
                      ),
                      _buildNumberedPoint(
                        3,
                        "Follow our team's guidance to receive your return authorization.",
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Return Shipping',
                    icon: Icons.local_shipping_outlined,
                    brandColor: brandColor,
                    children: [
                      const Text(
                        'Customers are responsible for the cost of return shipping unless the return is due to an error on our part or a defective product. For your protection, we recommend using a trackable shipping service when returning items.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Refund & Timeframe',
                    icon: Icons.account_balance_wallet_outlined,
                    brandColor: brandColor,
                    children: [
                      _buildBulletPoint(
                        'Refunds will be issued to the original payment method used for the purchase.',
                      ),
                      _buildBulletPoint(
                        'Please allow up to 7 business days for the refund to be processed and reflected in your account.',
                      ),
                      _buildBulletPoint(
                        'The exact timeframe may vary depending on your payment provider.',
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Damaged or Defective Items',
                    icon: Icons.report_problem_outlined,
                    brandColor: brandColor,
                    children: [
                      const Text(
                        'If you receive a damaged or defective item, please contact our customer support team immediately for assistance. We will arrange for a replacement or issue a refund, depending on the circumstances.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Exchange Policy',
                    icon: Icons.swap_horiz_rounded,
                    brandColor: brandColor,
                    children: [
                      const Text(
                        'Currently, Nilkanth Store Trade Name : ILAVIZ does not offer exchanges. If you require a different item, color, or size, please initiate a return for the unwanted item and place a new order for the desired item.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  _buildContactCard(brandColor),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: brandColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: brandColor.withOpacity(0.1)),
                    ),
                    child: const Text(
                      'Thank you for choosing Nilkanth Store. We appreciate your business and strive to provide a hassle-free shopping experience.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textPrimary,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const WhatsAppButton(message: 'Jay Swaminarayan'),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color brandColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: brandColor, size: 22),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: brandColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedPoint(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Color brandColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.contact_support_outlined, color: brandColor),
              const SizedBox(width: 12),
              Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: brandColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            Icons.email_outlined,
            'shrinilkanthstore@gmail.com',
            _launchEmail,
            brandColor,
            isLink: true,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.phone_outlined,
            '+91 82388 11190',
            _launchPhone,
            brandColor,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String text,
    VoidCallback onTap,
    Color brandColor, {
    bool isLink = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: brandColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: brandColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: brandColor,
                  fontWeight: FontWeight.w600,
                  decoration: isLink ? TextDecoration.underline : null,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
