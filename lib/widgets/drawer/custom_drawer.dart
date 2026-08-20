import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pujanam/pages/auth/login.dart';
import 'package:pujanam/pages/categories/category_list_screen.dart';
import 'package:pujanam/theme/app_color.dart';
import 'package:pujanam/widgets/drawer/about_us.dart';
import 'package:pujanam/widgets/drawer/blog.dart';
import 'package:pujanam/widgets/drawer/contect_us.dart';
import 'package:pujanam/widgets/drawer/policies/privacy_policy.dart';
import 'package:pujanam/widgets/drawer/policies/return_policy.dart';
import 'package:pujanam/widgets/drawer/policies/shipping_policy.dart';
import 'package:pujanam/widgets/drawer/policies/terms_condition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _email = 'User';
  bool _isLoggedIn = false;
  final Color brandColor = AppColors.primary;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Function to fetch the email and accessToken from SharedPreferences
  Future<void> _fetchUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');
      String? accessToken = prefs.getString('accessToken');
      if (mounted) {
        setState(() {
          _email = (email != null && email.isNotEmpty) ? email : 'User';
          _isLoggedIn = accessToken != null;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          _email = 'User';
          _isLoggedIn = false;
        });
      }
    }
  }

  // Function to launch URLs
  Future<void> _launchURL(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showSnackBar(context, 'Could not open $url');
      }
    } catch (e) {
      _showSnackBar(context, 'Error launching URL: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: brandColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Function to handle navigation
  void _handleNavigation(BuildContext context, String title) {
    switch (title) {
      case 'Return & Refund':
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReturnPolicyScreen()),
        );
        break;
      case 'Privacy Policy':
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
        );
        break;
      case 'Terms and Conditions':
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
        );
        break;
      case 'Shipping Policy':
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShippingPolicyScreen()),
        );
        break;
      case 'About Us':
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutUsScreen()),
        );
        break;
      case 'Contact Us':
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Contactus()),
        );
        break;
      case 'Blogs':
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BlogListScreen()),
        );
        break;
      case 'Bulk Order':
        _launchURL('https://store.nilkanthdham.in/bulk-order', context);
        break;
    }
  }

  // Widget to build styled ListTile - Tightened spacing and brand styling
  Widget _buildStyledListTile({
    required dynamic icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: brandColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: icon is IconData
              ? Icon(icon, color: brandColor, size: 18)
              : (icon is Widget
                    ? icon
                    : FaIcon(icon, color: brandColor, size: 18)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  // Widget to build styled ExpansionTile - Tightened spacing
  Widget _buildStyledExpansionTile({
    required dynamic icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: icon is IconData
                ? Icon(icon, color: brandColor, size: 18)
                : (icon is Widget
                      ? icon
                      : FaIcon(icon, color: brandColor, size: 18)),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      backgroundColor: Colors.grey[50],
      child: Column(
        children: [
          // Header Section - Simplified as requested
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [brandColor, brandColor.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildStyledListTile(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  onTap: () => Navigator.pop(context),
                ),
                _buildStyledListTile(
                  icon: Icons.category_outlined,
                  title: 'Categories',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryListScreen(),
                      ),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Divider(height: 1, color: AppColors.divider),
                ),
                _buildStyledExpansionTile(
                  icon: Icons.policy_outlined,
                  title: 'Policies',
                  children: [
                    _buildStyledListTile(
                      icon: Icons.assignment_return_outlined,
                      title: 'Return & Refund',
                      onTap: () =>
                          _handleNavigation(context, 'Return & Refund'),
                    ),
                    _buildStyledListTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _handleNavigation(context, 'Privacy Policy'),
                    ),
                    _buildStyledListTile(
                      icon: Icons.gavel_outlined,
                      title: 'Terms & Conditions',
                      onTap: () =>
                          _handleNavigation(context, 'Terms and Conditions'),
                    ),
                    _buildStyledListTile(
                      icon: Icons.local_shipping_outlined,
                      title: 'Shipping Policy',
                      onTap: () =>
                          _handleNavigation(context, 'Shipping Policy'),
                    ),
                  ],
                ),
                _buildStyledListTile(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () => _handleNavigation(context, 'About Us'),
                ),
                _buildStyledListTile(
                  icon: Icons.contact_mail_outlined,
                  title: 'Contact Us',
                  onTap: () => _handleNavigation(context, 'Contact Us'),
                ),
                // _buildStyledListTile(
                //   icon: Icons.temple_hindu_outlined,
                //   title: 'Daily Darshan',
                //   onTap: () => _handleNavigation(context, 'Daily Darshan'),
                // ),
                _buildStyledListTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Bulk Order',
                  onTap: () => _handleNavigation(context, 'Bulk Order'),
                ),
                _buildStyledListTile(
                  icon: Icons.article_outlined,
                  title: 'Blogs',
                  onTap: () => _handleNavigation(context, 'Blogs'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Divider(height: 1, color: AppColors.divider),
                ),
                _buildStyledExpansionTile(
                  icon: FaIcon(
                    FontAwesomeIcons.shareNodes,
                    color: brandColor,
                    size: 16,
                  ),
                  title: 'Social Media',
                  children: [
                    _buildStyledListTile(
                      icon: FontAwesomeIcons.instagram,
                      title: 'Instagram',
                      onTap: () => _launchURL(
                        'https://www.instagram.com/nilkanthstore/',
                        context,
                      ),
                    ),
                    _buildStyledListTile(
                      icon: FontAwesomeIcons.facebook,
                      title: 'Facebook',
                      onTap: () => _launchURL(
                        'https://www.facebook.com/NilkanthStore/',
                        context,
                      ),
                    ),
                    _buildStyledListTile(
                      icon: FontAwesomeIcons.whatsapp,
                      title: 'WhatsApp',
                      onTap: () => _launchURL(
                        'https://api.whatsapp.com/send?phone=+919310501040&text=hello',
                        context,
                      ),
                    ),
                    _buildStyledListTile(
                      icon: FontAwesomeIcons.youtube,
                      title: 'YouTube',
                      onTap: () => _launchURL(
                        'https://www.youtube.com/@nilkanthstore',
                        context,
                      ),
                    ),
                  ],
                ),
                if (_isLoggedIn) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Divider(height: 1, color: AppColors.divider),
                  ),
                  _buildStyledListTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Logout',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'Poppins',
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'No',
                style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Yes', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }
}
