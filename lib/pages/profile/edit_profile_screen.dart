import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/customer/customer_address.dart';
import '../../providers/customer/customer_provider.dart';

const _brand = Color.fromRGBO(111, 10, 15, 1);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _addressLine1 = TextEditingController();
  final _addressLine2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postalCode = TextEditingController();
  CustomerAddress? _currentAddress;

  @override
  void initState() {
    super.initState();
    final customer = context.read<CustomerProvider>();
    final profile = customer.profile;
    _currentAddress =
        customer.addresses.where((address) => address.isDefault).firstOrNull ??
        (customer.addresses.isEmpty ? null : customer.addresses.first);
    _firstName.text = profile?.firstName ?? '';
    _lastName.text = profile?.lastName ?? '';
    _email.text = profile?.email ?? '-';
    _phone.text = profile?.phoneNumber ?? '';
    _addressLine1.text = _currentAddress?.addressLine1 ?? '';
    _addressLine2.text = _currentAddress?.addressLine2 ?? '';
    _city.text = _currentAddress?.city ?? '';
    _state.text = _currentAddress?.state ?? '';
    _postalCode.text = _currentAddress?.postalCode ?? '';
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _addressLine1.dispose();
    _addressLine2.dispose();
    _city.dispose();
    _state.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  bool get _hasAddressInput => [
    _addressLine1,
    _addressLine2,
    _city,
    _state,
    _postalCode,
  ].any((controller) => controller.text.trim().isNotEmpty);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final customer = context.read<CustomerProvider>();
    final address = _hasAddressInput
        ? CustomerAddress(
            id: _currentAddress?.id ?? '',
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            addressLine1: _addressLine1.text.trim(),
            addressLine2: _addressLine2.text.trim().isEmpty
                ? null
                : _addressLine2.text.trim(),
            addressType: _currentAddress?.addressType ?? 'shipping',
            city: _city.text.trim(),
            state: _state.text.trim(),
            postalCode: _postalCode.text.trim(),
            countryCode: _currentAddress?.countryCode ?? 'IN',
            phoneNumber: _phone.text.trim(),
            isDefault: _currentAddress?.isDefault ?? true,
            createdAt: _currentAddress?.createdAt ?? DateTime.now(),
            updatedAt: DateTime.now(),
          )
        : null;
    final success = await customer.saveProfileAndAddress(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: (_email.text.trim().isEmpty || _email.text.trim() == '-')
          ? null
          : _email.text.trim(),
      phoneNumber: _phone.text.trim(),
      address: address,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(customer.errorMessage ?? 'Unable to update profile.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<CustomerProvider>().isSaving;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: _brand,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Your Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _brand,
                ),
              ),
              const SizedBox(height: 16),
              _field(_firstName, 'First Name'),
              _field(_lastName, 'Last Name'),
              _field(_email, 'Email', keyboardType: TextInputType.emailAddress),
              _field(
                _phone,
                'Phone',
                keyboardType: TextInputType.phone,
                phone: true,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 12),
                child: Text(
                  'Shipping Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _brand,
                  ),
                ),
              ),
              _field(
                _addressLine1,
                'Address Line 1',
                required: _hasAddressInput,
              ),
              _field(_addressLine2, 'Address Line 2'),
              Row(
                children: [
                  Expanded(
                    child: _field(_city, 'City', required: _hasAddressInput),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _field(
                      _postalCode,
                      'Pincode',
                      keyboardType: TextInputType.number,
                      pincode: true,
                      required: _hasAddressInput,
                    ),
                  ),
                ],
              ),
              _field(_state, 'State', required: _hasAddressInput),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
    bool required = false,
    bool pincode = false,
    bool phone = false,
    TextInputType? keyboardType,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: (_) {
        if (mounted) setState(() {});
      },
      decoration: InputDecoration(
        labelText: label,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[200] : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _brand, width: 2),
        ),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (required && text.isEmpty) {
          return 'Please enter $label';
        }
        if (pincode && text.isNotEmpty && !RegExp(r'^\d{6}$').hasMatch(text)) {
          return 'Pincode must be 6 digits';
        }
        if (phone && text.isEmpty) {
          return 'Mobile number is required';
        }
        return null;
      },
    ),
  );
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
