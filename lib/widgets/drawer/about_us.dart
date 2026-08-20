import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pujanam/theme/app_color.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  void _launchURL(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the link'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

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
          'About Us',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: brandColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    'Nilkanth Store',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    '(Trade Name : ILAVIZ)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '"Guided by devotion, integrity, and purpose. We aim to bring lasting value to every soul we connect with — from our customers and artisans to the communities and traditions we proudly uphold."',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 1: Sacred Responsibility
            _buildContentSection(
              context,
              image: 'assets/images/about_1.webp',
              title: 'Sacred Responsibility',
              content:
                  'At Nilkanth Store Trade Name : ILAVIZ, we honor tradition with responsibility. Our products are thoughtfully sourced and crafted using ethical practices that respect both nature and spirituality. By supporting sustainable craftsmanship, we not only preserve cultural heritage but also uplift the artisans and communities behind each sacred creation.',
              buttonText: 'Explore our products',
              brandColor: brandColor,
            ),

            // Section 2: Who we are
            _buildContentSection(
              context,
              image: 'assets/images/about_2.webp',
              title: 'Who we are',
              subtitle: 'Tradition with Purpose',
              content:
                  'At Nilkanth Store Trade Name : ILAVIZ, we are devoted to bringing purity, tradition, and spiritual grace into every home. Rooted in the essence of Indian rituals, our mission is to preserve sacred customs while making them accessible for the modern devotee. Every product we offer is a reflection of our commitment to authenticity, devotion, and trust.',
              buttonText: 'Discover Now',
              brandColor: brandColor,
            ),

            // Section 3: Our Purpose
            _buildContentSection(
              context,
              image: 'assets/images/about_3.webp',
              title: 'Our Purpose',
              subtitle: 'Our Commitment',
              content:
                  "At Nilkanth Store Trade Name : ILAVIZ, our purpose is to make every spiritual moment more meaningful — by offering products that help you connect deeply with your faith, traditions, and inner peace. Rooted in a profound understanding of pooja practices and cultural significance, we are honored to be part of countless sacred rituals across homes and temples.\n\nWe also believe that spirituality and sustainability go hand in hand. That's why we are committed to using eco-friendly materials and reducing waste — honoring not just the divine, but also the Earth that sustains us.",
              buttonText: 'Learn more',
              brandColor: brandColor,
            ),

            // Contact Section

            // Connect With Us Section
            _buildSocialMediaSection(context, brandColor),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(
    BuildContext context, {
    required String image,
    required String title,
    String? subtitle,
    required String content,
    required String buttonText,
    required Color brandColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              image,
              height: 240,
              width: double.infinity,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle.toUpperCase(),
                    style: TextStyle(
                      color: brandColor.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontFamily: 'Poppins',
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: brandColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),
                // OutlinedButton(
                //   onPressed: () {}, // Navigation can be added later
                //   style: OutlinedButton.styleFrom(
                //     foregroundColor: brandColor,
                //     side: BorderSide(color: brandColor.withOpacity(0.5)),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     textStyle: const TextStyle(
                //       fontSize: 13,
                //       fontWeight: FontWeight.bold,
                //       fontFamily: 'Poppins',
                //     ),
                //   ),
                //   child: Text(buttonText),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, Color brandColor) {
    return Row(
      children: [
        Icon(icon, color: brandColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaSection(BuildContext context, Color brandColor) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Connect With Us',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
              FontAwesomeIcons.facebook,
              'https://www.facebook.com/NilkanthStore/',
              context,
              brandColor,
            ),
            const SizedBox(width: 15),
            _buildSocialIcon(
              FontAwesomeIcons.whatsapp,
              'https://api.whatsapp.com/send?phone=+918238811190&text=hello',
              context,
              brandColor,
            ),
            const SizedBox(width: 15),
            _buildSocialIcon(
              FontAwesomeIcons.instagram,
              'https://www.instagram.com/nilkanthstore/',
              context,
              brandColor,
            ),
            const SizedBox(width: 15),
            _buildSocialIcon(
              FontAwesomeIcons.youtube,
              'https://www.youtube.com/@nilkanthstore',
              context,
              brandColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(
    FaIconData icon,
    String url,
    BuildContext context,
    Color brandColor,
  ) {
    return InkWell(
      onTap: () => _launchURL(url, context),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: brandColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: FaIcon(icon, color: brandColor, size: 20),
      ),
    );
  }
}
