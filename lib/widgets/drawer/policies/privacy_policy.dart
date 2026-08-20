import 'package:flutter/material.dart';
import 'package:pujanam/theme/app_color.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../whastapp.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final Color brandColor = AppColors.primary;

    return Scaffold(
      floatingActionButton: WhatsAppButton(message: 'Jay Swaminarayan'),
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: brandColor,
        title: const Text(
          'Privacy Policy',
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
                    child: const Column(
                      children: [
                        Text(
                          'Nilkanth Store',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          '(Trade Name : ILAVIZ)',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '"Welcome to Nilkanth Store Trade Name : ILAVIZ, your online destination for divine offerings and spiritual fulfillment."',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This Privacy Policy outlines how we handle your personal information on our website. We are committed to safeguarding your privacy and ensuring that your information is handled responsibly and in compliance with applicable laws.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildSection(
                    title: 'Information We Collect',
                    icon: Icons.data_usage_rounded,
                    brandColor: brandColor,
                    children: [
                      _buildSubSection('A. Personal Information', [
                        _buildInfoTile(Icons.person_outline, 'Name'),
                        _buildInfoTile(
                          Icons.alternate_email,
                          'Contact details',
                        ),
                        _buildInfoTile(
                          Icons.location_on_outlined,
                          'Billing & Shipping address',
                        ),
                        _buildInfoTile(
                          Icons.payment_outlined,
                          'Payment information',
                        ),
                      ]),
                      const SizedBox(height: 10),
                      _buildSubSection('B. Transaction Details', [
                        _buildInfoTile(Icons.history_rounded, 'Order history'),
                        _buildInfoTile(
                          Icons.receipt_outlined,
                          'Payment records',
                        ),
                        _buildInfoTile(
                          Icons.description_outlined,
                          'Invoices and receipts',
                        ),
                      ]),
                      const SizedBox(height: 10),
                      _buildSubSection('C. Device & Usage', [
                        _buildInfoTile(
                          Icons.language_rounded,
                          'IP address & Browser type',
                        ),
                        _buildInfoTile(
                          Icons.devices_other_rounded,
                          'Operating system',
                        ),
                        _buildInfoTile(
                          Icons.ads_click_rounded,
                          'Site interactions',
                        ),
                      ]),
                    ],
                  ),

                  _buildSection(
                    title: 'How We Collect',
                    icon: Icons.cloud_download_outlined,
                    brandColor: brandColor,
                    children: [
                      _buildBulletPoint('Creating an account'),
                      _buildBulletPoint('Making a purchase'),
                      _buildBulletPoint('Contacting customer support'),
                      _buildBulletPoint('Interacting with the website'),
                    ],
                  ),

                  _buildSection(
                    title: 'Purpose of Collection',
                    icon: Icons.assignment_turned_in_outlined,
                    brandColor: brandColor,
                    children: [
                      _buildBulletPoint(
                        'Efficient order processing and fulfillment',
                      ),
                      _buildBulletPoint('Providing excellent customer support'),
                      _buildBulletPoint(
                        'Analyzing site usage to optimize experience',
                      ),
                      _buildBulletPoint('Complying with legal obligations'),
                    ],
                  ),

                  _buildSection(
                    title: 'Sharing of Information',
                    icon: Icons.share_outlined,
                    brandColor: brandColor,
                    children: [
                      const Text(
                        'We may share Personal Information with service providers (e.g., payment processors, shipping companies) and legal authorities when required by law.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Security Measures',
                    icon: Icons.shield_outlined,
                    brandColor: brandColor,
                    children: [
                      const Text(
                        'We implement industry-standard security measures to protect your Personal Information from unauthorized access, disclosure, or alteration.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Your Privacy Rights',
                    icon: Icons.verified_user_outlined,
                    brandColor: brandColor,
                    children: [
                      const Text(
                        'As a user of Nilkanth Store Trade Name : ILAVIZ, you have absolute control over your data.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildNumberedPoint(1, 'Access your Information'),
                      _buildNumberedPoint(2, 'Correct inaccuracies'),
                      _buildNumberedPoint(3, 'Withdraw consent'),
                      _buildNumberedPoint(4, 'Request erasure'),
                      _buildNumberedPoint(5, 'Object to processing'),
                      _buildNumberedPoint(6, 'Data portability'),
                    ],
                  ),

                  _buildSection(
                    title: 'Governing Law',
                    icon: Icons.gavel_outlined,
                    brandColor: brandColor,
                    children: [
                      const Text(
                        'This Privacy Policy is governed by and construed in accordance with the laws of Rajpipla, Narmada, Gujarat. Disputes shall be subject to the exclusive jurisdiction of the courts in Rajpipla.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Consent',
                    icon: Icons.check_circle_outline,
                    brandColor: brandColor,
                    children: [
                      const Text(
                        'By using Nilkanth Store Trade Name : ILAVIZ, you consent to the collection and use of your Personal Information as outlined in this Privacy Policy.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),

                  _buildContactSection(brandColor),

                  const SizedBox(height: 20),
                  _buildWebsiteLink(brandColor),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildSubSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontFamily: 'Poppins',
              ),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
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
          Text(
            text,
            style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(Color brandColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: brandColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brandColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            'For inquiries or concerns, please contact us at:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _launchEmail,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email_outlined, color: brandColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  'shrinilkanthstore@gmail.com',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: brandColor,
                    decoration: TextDecoration.underline,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteLink(Color brandColor) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _launchURL('https://store.nilkanthdham.in/'),
        icon: Icon(Icons.language, color: brandColor, size: 18),
        label: Text(
          'Visit store.nilkanthdham.in',
          style: TextStyle(
            fontSize: 14,
            color: brandColor,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
