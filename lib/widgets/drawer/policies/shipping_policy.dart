import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pujanam/theme/app_color.dart';
import 'package:url_launcher/url_launcher.dart';

class ShippingPolicyScreen extends StatelessWidget {
  const ShippingPolicyScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $uri');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

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
          'Shipping Policy',
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
                      'Thank you for choosing Nilkanth Store Trade Name : ILAVIZ for your spiritual and wellness needs.',
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
                    'Our Shipping Policy outlines the details of how we handle shipping and delivery of our products.',
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
                    title: 'Processing & Delivery',
                    icon: Icons.timer_outlined,
                    brandColor: brandColor,
                    children: [
                      _buildBulletPoint(
                        'Processing Time: Orders are typically processed within 1–2 business days. Peak seasons or holidays may affect this.',
                      ),
                      _buildBulletPoint(
                        'Delivery Time: Typically delivered within 5–10 business days after processing, depending on location.',
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Shipping Destinations',
                    icon: Icons.map_outlined,
                    brandColor: brandColor,
                    children: [
                      const Text(
                        'Nilkanth Store Trade Name : ILAVIZ currently offers shipping within India. We are committed to providing reliable and efficient shipping services across the country.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Methods & Charges',
                    icon: Icons.local_shipping_outlined,
                    brandColor: brandColor,
                    children: [
                      _buildBulletPoint(
                        'Shipping Methods: We partner with trusted logistics providers. Available methods are shown during checkout.',
                      ),
                      _buildBulletPoint(
                        'Shipping Charges: Calculated based on weight, destination, and method. Total cost is shown at checkout.',
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Tracking & Delivery',
                    icon: Icons.track_changes_rounded,
                    brandColor: brandColor,
                    children: [
                      _buildBulletPoint(
                        "Tracking: You'll receive a confirmation email with a tracking number. You can also track via 'Order History' in your account.",
                      ),
                      _buildBulletPoint(
                        'Attempts: Reasonable attempts will be made. If unavailable, they may leave a notification or contact you to reschedule.',
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Updates & Restrictions',
                    icon: Icons.update_rounded,
                    brandColor: brandColor,
                    children: [
                      _buildBulletPoint(
                        'Updates: Regular updates via email including confirmation, shipment notification, and tracking info.',
                      ),
                      _buildBulletPoint(
                        'Restrictions: Certain locations may be unavailable. We will notify you promptly and process a refund if affected.',
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
                    child: const Column(
                      children: [
                        Icon(
                          Icons.security_outlined,
                          color: AppColors.primary,
                          size: 30,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Safe & Secure Delivery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'We ensure your orders are handled with care and delivered safely to your doorstep.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.textSecondary,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final Uri whatsappUri = Uri.parse(
            'https://wa.me/918238811190?text=Jay%20Swaminarayan',
          );
          launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        },
        backgroundColor: const Color(0xFF25D366),
        child: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
      ),
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
