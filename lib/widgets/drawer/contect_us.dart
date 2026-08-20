import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pujanam/theme/app_color.dart';
import 'package:url_launcher/url_launcher.dart';

class Contactus extends StatelessWidget {
  const Contactus({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandColor = AppColors.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: brandColor,
        title: const Text(
          'Contact Us',
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
                    'Get in Touch with Us',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nilkanth Store Trade Name : ILAVIZ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Contact Info Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildContactCard(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    content: '+91 82388 11190',
                    brandColor: brandColor,
                    onTap: () => _launchPhone('+918238811190'),
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    content: 'shrinilkanthstore@gmail.com',
                    brandColor: brandColor,
                    onTap: () => _launchEmail(),
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    icon: Icons.location_on_outlined,
                    title: 'Address',
                    content:
                        'Nilkanth Store Trade Name : ILAVIZ, Ground floor, Block / Survey No - 557, Shree Swaminarayan Gurukul Trust, Poicha Swaminarayan Temple, Narmada, Gujarat - 393145',
                    brandColor: brandColor,
                    onTap: () => _launchLocation(
                      'Poicha Swaminarayan Temple, Narmada, Gujarat',
                    ),
                  ),

                  // Additional Info Section
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: brandColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: brandColor.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.support_agent_rounded,
                          size: 40,
                          color: brandColor,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Customer Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: brandColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'We are here to help! Contact us for any queries or support needed. Our team will get back to you as soon as possible.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.grey[700],
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
            const SizedBox(height: 80),
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required Color brandColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: brandColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: brandColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textSecondary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      debugPrint('Could not launch $phoneUri');
    }
  }

  Future<void> _launchEmail() async {
    final Uri uri = Uri.parse('mailto:shrinilkanthstore@gmail.com');
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $uri');
    }
  }

  void _launchLocation(String location) async {
    String query = Uri.encodeComponent(location);
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}
