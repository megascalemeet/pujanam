import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/customer/customer_address.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/customer/customer_provider.dart';
import '../auth/login.dart';
import 'edit_profile_screen.dart';

const _brand = Color.fromRGBO(111, 10, 15, 1);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CustomerProvider>().loadCustomer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fa),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _brand,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, customer, _) {
          if (customer.isLoading && customer.profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: _brand),
            );
          }
          if (customer.profile == null) return _error(customer);
          final profile = customer.profile!;
          final address =
              customer.addresses.where((item) => item.isDefault).firstOrNull ??
              (customer.addresses.isEmpty ? null : customer.addresses.first);
          return RefreshIndicator(
            color: _brand,
            onRefresh: customer.loadCustomer,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.only(bottom: 42),
              children: [
                _profileHeader(
                  profile.firstName,
                  profile.lastName,
                  profile.phoneNumber,
                  profile.isVerified,
                  customer.isSaving,
                ),
                const SizedBox(height: 16),
                _dashboard(
                  profile.firstName,
                  profile.lastName,
                  profile.email ?? '',
                  profile.phoneNumber,
                  address,
                ),
                const SizedBox(height: 32),
                _logoutButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileHeader(
    String firstName,
    String lastName,
    String phone,
    bool verified,
    bool saving,
  ) {
    final name = '$firstName $lastName'.trim();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(24),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [_brand, Color.fromRGBO(111, 10, 15, .35)],
                  ),
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 45, color: _brand),
                ),
              ),
              if (verified)
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, size: 13, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Customer' : name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone.isEmpty ? 'No phone number' : phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: saving ? null : () => _openEditProfile(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(111, 10, 15, .05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_rounded, size: 20, color: _brand),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboard(
    String firstName,
    String lastName,
    String email,
    String phone,
    CustomerAddress? address,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration(28),
      child: Column(
        children: [
          _section('Account Details', [
            _tile(Icons.person_outline, 'First Name', firstName),
            _tile(Icons.person_outline, 'Last Name', lastName),
            _tile(Icons.email_outlined, 'Email', email),
            _tile(Icons.phone_outlined, 'Phone', phone),
          ]),
          const Divider(height: 1, indent: 24, endIndent: 24),
          _section(
            'Shipping Address',
            address == null
                ? [
                    _tile(
                      Icons.location_on_outlined,
                      'Address',
                      'No saved address',
                    ),
                  ]
                : [
                    _tile(
                      Icons.location_on_outlined,
                      'Address',
                      '${address.addressLine1}${address.addressLine2?.isNotEmpty == true ? ', ${address.addressLine2}' : ''}',
                    ),
                    _compactRow(
                      'City',
                      address.city,
                      'Pincode',
                      address.postalCode,
                    ),
                    _compactRow(
                      'State',
                      address.state,
                      'Country',
                      address.countryCode,
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _section(String heading, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Text(
          heading.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(111, 10, 15, .6),
            letterSpacing: 2,
          ),
        ),
      ),
      ...children,
      const SizedBox(height: 16),
    ],
  );

  Widget _tile(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(111, 10, 15, .03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: const Color.fromRGBO(111, 10, 15, .7),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _compactRow(
    String leftLabel,
    String left,
    String rightLabel,
    String right,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Row(
      children: [
        Expanded(child: _compact(leftLabel, left)),
        Container(width: 1, height: 30, color: Colors.grey[200]),
        Expanded(child: _compact(rightLabel, right)),
      ],
    ),
  );

  Widget _compact(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );

  BoxDecoration _cardDecoration(double radius) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, .05),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  );

  Widget _logoutButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: TextButton.icon(
      onPressed: _logout,
      icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
      label: const Text(
        'Sign Out Account',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color.fromRGBO(244, 67, 54, .2)),
        ),
      ),
    ),
  );

  Widget _error(CustomerProvider customer) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_person_rounded, size: 72, color: _brand),
          const SizedBox(height: 22),
          Text(
            customer.errorMessage ?? 'Please sign in to view your profile.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: _brand),
            child: const Text('Sign In'),
          ),
        ],
      ),
    ),
  );

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (updated == true && mounted) {
      await context.read<CustomerProvider>().loadCustomer();
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: _brand)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) {
      return;
    }
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
