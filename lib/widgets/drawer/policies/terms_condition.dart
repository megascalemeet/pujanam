import 'package:flutter/material.dart';
import 'package:pujanam/theme/app_color.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: brandColor,
        title: const Text(
          'Terms of Service',
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
                    'Welcome to Nilkanth Store',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Text(
                    '(Trade Name : ILAVIZ)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Please read these terms carefully before using our services',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Terms Sections
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSection(
                    'OVERVIEW',
                    'Welcome to Nilkanth Store Trade Name : ILAVIZ! These Terms and Conditions govern your use of our website and services. By accessing or using our website, you agree to comply with these terms. Please read them carefully before proceeding.',
                    Icons.info_outline,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 1 - ONLINE STORE TERMS',
                    '1.1 By agreeing to these Terms, you confirm that you are at least the age of majority in your state or province of residence.\n\n'
                        '1.2 You may not use our products for any illegal or unauthorized purpose, nor violate any laws in your jurisdiction (including but not limited to copyright laws).\n\n'
                        '1.3 You must not transmit any worms or viruses or any code of a destructive nature.\n\n'
                        '1.4 A breach or violation of any of the Terms will result in an immediate termination of your Services.',
                    Icons.store_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 2 - GENERAL CONDITIONS',
                    '2.1 We reserve the right to refuse service to anyone for any reason at any time.\n\n'
                        '2.2 You understand that your content (not including credit card information) may be transferred unencrypted and involve (a) transmissions over various networks and (b) changes to conform and adapt to the technical requirements of connecting networks or devices.\n\n'
                        '2.3 You agree not to reproduce, duplicate, copy, sell, resell, or exploit any portion of the Service, use of the Service, or access to the Service without express written permission by us.',
                    Icons.gavel_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 3 - ACCURACY, COMPLETENESS AND TIMELINESS OF INFORMATION',
                    '3.1 We are not responsible if the information made available on this site is not accurate, complete, or current.\n\n'
                        '3.2 The material on this site is provided for general information only and should not be relied upon as the sole basis for making decisions without consulting primary, more accurate, or more timely sources of information.',
                    Icons.update_rounded,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 4 - MODIFICATIONS TO THE SERVICE AND PRICES',
                    '4.1 Prices for our products are subject to change without notice.\n\n'
                        '4.2 We reserve the right to modify or discontinue the Service (or any part or content thereof) without notice at any time.\n\n'
                        '4.3 We shall not be liable to you or to any third party for any modification, price change, suspension, or discontinuance of the Service.',
                    Icons.edit_calendar_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 5 - PRODUCTS OR SERVICES (if applicable)',
                    '5.1 Certain products or services may be available exclusively online through the website.\n\n'
                        '5.2 We have made every effort to display as accurately as possible the colors and images of our products that appear at the store.\n\n'
                        '5.3 We reserve the right, but are not obligated, to limit the sales of our products or Services to any person, geographic region, or jurisdiction.',
                    Icons.shopping_bag_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 6 - ACCURACY OF BILLING AND ACCOUNT INFORMATION',
                    '6.1 We reserve the right to refuse any order you place with us.\n\n'
                        '6.2 You agree to provide current, complete, and accurate purchase and account information for all purchases made at our store.\n\n'
                        '6.3 For more detail, please review our Returns Policy.',
                    Icons.account_balance_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 7 - OPTIONAL TOOLS',
                    '7.1 We may provide you with access to third-party tools over which we neither monitor nor have any control nor input.\n\n'
                        '7.2 You acknowledge and agree that we provide access to such tools "as is" and "as available" without any warranties, representations, or conditions of any kind.',
                    Icons.build_circle_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 8 - THIRD-PARTY LINKS',
                    '8.1 Certain content, products, and services available via our Service may include materials from third-parties.\n\n'
                        '8.2 Third-party links on this site may direct you to third-party websites that are not affiliated with us.',
                    Icons.link_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 9 - USER COMMENTS, FEEDBACK AND OTHER SUBMISSIONS',
                    '9.1 If, at our request, you send certain specific submissions (for example, contest entries) or without a request from us you send creative ideas, suggestions, proposals, plans, or other materials, you agree that we may, at any time, without restriction, edit, copy, publish, distribute, translate, and otherwise use in any medium any comments that you forward to us.\n\n'
                        '9.2 We are and shall be under no obligation (1) to maintain any comments in confidence; (2) to pay compensation for any comments; or (3) to respond to any comments.',
                    Icons.comment_bank_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 10 - PERSONAL INFORMATION',
                    '10.1 Your submission of personal information through the store is governed by our Privacy Policy.',
                    Icons.person_pin_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 11 - ERRORS, INACCURACIES AND OMISSIONS',
                    '11.1 Occasionally there may be information on our site or in the Service that contains typographical errors, inaccuracies, or omissions.',
                    Icons.report_problem_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 12 - PROHIBITED USES',
                    '12.1 In addition to other prohibitions as set forth in the Terms of Service, you are prohibited from using the site or its content for any unlawful purpose; to violate any laws; to infringe on intellectual property rights; to harass, abuse, or discriminate against others; or to submit false information.',
                    Icons.block_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 13 - DISCLAIMER OF WARRANTIES; LIMITATION OF LIABILITY',
                    '13.1 We do not guarantee that your use of our service will be uninterrupted, timely, secure, or error-free.\n\n'
                        '13.2 You expressly agree that your use of the service is at your sole risk. All products and services are provided "as is" and "as available" without warranties.\n\n'
                        '13.3 In no case shall Nilkanth Store Trade Name : ILAVIZ or its affiliates be liable for any damages, including lost profits or savings, arising from your use of the Service.',
                    Icons.warning_amber_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 14 - INDEMNIFICATION',
                    '14.1 You agree to indemnify and hold Nilkanth Store Trade Name : ILAVIZ harmless from any claim arising from your breach of these Terms or violation of any law.',
                    Icons.security_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 15 - SEVERABILITY',
                    '15.1 If any provision of these Terms is deemed unlawful or unenforceable, it will be enforced to the fullest extent permitted, and the remainder of the Terms will remain in effect.',
                    Icons.check_circle_outline,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 16 - TERMINATION',
                    '16.1 These Terms are effective unless and until terminated by you or us. We may terminate the agreement at any time for any breach or violation of these Terms.',
                    Icons.cancel_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 17 - ENTIRE AGREEMENT',
                    '17.1 These Terms constitute the entire agreement between you and us and supersede any prior agreements.',
                    Icons.handshake_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 18 - GOVERNING LAW',
                    '18.1 These Terms are governed by the laws of India.',
                    Icons.public_outlined,
                    brandColor,
                  ),
                  _buildSection(
                    'SECTION 19 - CHANGES TO TERMS OF SERVICE',
                    '19.1 We reserve the right to update or modify these Terms at any time. It is your responsibility to check this page for updates.',
                    Icons.history_outlined,
                    brandColor,
                  ),

                  // Contact Information Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SECTION 20 - CONTACT INFORMATION',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: brandColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildContactInfo(
                          Icons.email_outlined,
                          'shrinilkanthstore@gmail.com',
                          brandColor,
                          onTap: _launchEmail,
                        ),
                        _buildContactInfo(
                          Icons.phone_outlined,
                          '+91 82388 11190',
                          brandColor,
                          onTap: _launchPhone,
                        ),
                        _buildContactInfo(
                          Icons.location_on_outlined,
                          'Nilkanth Store Trade Name : ILAVIZ, Ground floor,\nBlock / Survey No - 557,\nShree Swaminarayan Gurukul Trust,\nPoicha Swaminarayan Temple,\nNarmada, Gujarat - 393145',
                          brandColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content,
    IconData icon,
    Color brandColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: brandColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  // Added Expanded to fix the text overflow error
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: brandColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(
    IconData icon,
    String text,
    Color brandColor, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: brandColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
