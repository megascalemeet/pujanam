import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/customer/customer_address.dart';
import '../../providers/customer/customer_provider.dart';
import 'add_edit_address_screen.dart';

const _brand = Color.fromRGBO(111, 10, 15, 1);

class AddMultipleAddresses extends StatefulWidget {
  const AddMultipleAddresses({super.key});

  @override
  State<AddMultipleAddresses> createState() => _AddMultipleAddressesState();
}

class _AddMultipleAddressesState extends State<AddMultipleAddresses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Addresses',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        //for add add..
        backgroundColor: _brand,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          final addresses = provider.addresses;
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No addresses saved yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _openAddEditAddress(context),
                    style: ElevatedButton.styleFrom(backgroundColor: _brand),
                    child: const Text(
                      'Add New Address',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return _addressCard(context, address, provider);
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _openAddEditAddress(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _brand,
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            'Add New Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _addressCard(
      BuildContext context,
      CustomerAddress address,
      CustomerProvider provider,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: address.isDefault
            ? Border.all(color: _brand.withValues(alpha: 0.5), width: 1.5)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${address.firstName} ${address.lastName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                    ),
                    if (address.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _brand,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                // const SizedBox(height: 6),
                Text(
                  address.addressLine1,
                  style: const TextStyle(
                    color: Colors.grey,
                    //color: Colors.black54,
                    fontSize: 14,
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (address.addressLine2?.isNotEmpty == true)
                  Text(
                    address.addressLine2!,
                    style: const TextStyle(
                      color: Colors.grey,
                      //color: Colors.black54,
                      fontSize: 14,
                      height: 1.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  '${address.city}, ${address.state}.',
                  style: const TextStyle(
                    color: Colors.grey,
                    //color: Colors.black54,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                // const SizedBox(height: 8),
                Text(
                  'Pincode : ${address.postalCode}',
                  style: const TextStyle(
                    color: Colors.grey,
                    //color: Colors.black54,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                //const SizedBox(height: 8),
                Text(
                  "Phone No : ${address.phoneNumber}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.3,
                    // fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey.shade200,
            endIndent: 15,
            indent: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!address.isDefault)
                  TextButton(
                    onPressed: () => provider.setDefaultAddress(address.id),
                    child: const Text(
                      'Set as Default',
                      style: TextStyle(
                        color: Colors.grey,
                        // _brand,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () =>
                      _openAddEditAddress(context, address: address),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: _brand,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      _confirmDelete(context, address.id, provider),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAddEditAddress(BuildContext context, {CustomerAddress? address}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditAddressScreen(address: address)),
    );
  }

  void _confirmDelete(
      BuildContext context,
      String id,
      CustomerProvider provider,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAddress(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
