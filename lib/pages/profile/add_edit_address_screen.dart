import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/customer/customer_address.dart';
import '../../providers/customer/customer_provider.dart';

const _brand = Color.fromRGBO(111, 10, 15, 1);

class AddEditAddressScreen extends StatefulWidget {
  final CustomerAddress? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _addressLine1 = TextEditingController();
  final _addressLine2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postalCode = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _firstName.text = widget.address!.firstName;
      _lastName.text = widget.address!.lastName;
      _phone.text = widget.address!.phoneNumber;
      _addressLine1.text = widget.address!.addressLine1;
      _addressLine2.text = widget.address!.addressLine2 ?? '';
      _city.text = widget.address!.city;
      _state.text = widget.address!.state;
      _postalCode.text = widget.address!.postalCode;
      _isDefault = widget.address!.isDefault;
    } else {
      final profile = context.read<CustomerProvider>().profile;
      _firstName.text = profile?.firstName ?? '';
      _lastName.text = profile?.lastName ?? '';
      _phone.text = profile?.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _addressLine1.dispose();
    _addressLine2.dispose();
    _city.dispose();
    _state.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CustomerProvider>();
    final address = CustomerAddress(
      id: widget.address?.id ?? '',
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      addressLine1: _addressLine1.text.trim(),
      addressLine2: _addressLine2.text.trim().isEmpty
          ? null
          : _addressLine2.text.trim(),
      addressType: 'shipping',
      city: _city.text.trim(),
      state: _state.text.trim(),
      postalCode: _postalCode.text.trim(),
      countryCode: 'IN',
      phoneNumber: _phone.text.trim(),
      isDefault: _isDefault,
      createdAt: widget.address?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (widget.address == null) {
      success = await provider.addAddress(address);
    } else {
      success = await provider.updateAddress(address);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save address'),
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
        title: Text(
          widget.address == null ? 'Add New Address' : 'Edit Address',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _brand,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      //edit address
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_firstName, 'First Name', required: true),
              _field(_lastName, 'Last Name', required: true),
              _field(
                _phone,
                'Phone Number',
                required: true,
                keyboardType: TextInputType.phone,
              ),
              _field(_addressLine1, 'Address Line 1', required: true),
              _field(_addressLine2, 'Address Line 2'),
              Row(
                children: [
                  Expanded(child: _field(_city, 'City', required: true)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _field(
                      _postalCode,
                      'Pincode',
                      required: true,
                      keyboardType: TextInputType.number,
                      pincode: true,
                    ),
                  ),
                ],
              ),
              _field(_state, 'State', required: true),
              SwitchListTile(
                title: const Text('Set as Default Address'),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
                activeColor: _brand,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Save Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
        bool required = false,
        bool pincode = false,
        TextInputType? keyboardType,
      }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _brand, width: 2),
        ),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (required && text.isEmpty) return 'Please enter $label';
        if (pincode && text.isNotEmpty && !RegExp(r'^\d{6}$').hasMatch(text)) {
          return 'Pincode must be 6 digits';
        }
        return null;
      },
    ),
  );
}
