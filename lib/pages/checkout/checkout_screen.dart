import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic>? cartData;
  final double? totalAmount;

  const CheckoutScreen({
    super.key,
    this.cartData,
    this.totalAmount,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _useStoredAddress = false;
  bool _showCouponField = false;

  // Form field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Static/Dummy data
  final Map<String, dynamic> _dummyCartData = {
    'items': [
      {
        'title': 'Premium Basmati Rice',
        'weight': '5 kg',
        'quantity': 2,
        'price': 450.00,
        'image': 'https://via.placeholder.com/150',
        'variantId': '1234567890',
      },
      {
        'title': 'Organic Wheat Flour',
        'weight': '2 kg',
        'quantity': 1,
        'price': 180.00,
        'image': 'https://via.placeholder.com/150',
        'variantId': '0987654321',
      },
      {
        'title': 'Extra Virgin Olive Oil',
        'weight': '1 L',
        'quantity': 1,
        'price': 850.00,
        'image': 'https://via.placeholder.com/150',
        'variantId': '1122334455',
      },
    ]
  };

  // Static coupon codes
  final List<Map<String, String>> _dummyCouponCodes = [
    {'code': 'SAVE10', 'fullText': 'SAVE10 - Get 10% off on your order'},
    {'code': 'WELCOME20', 'fullText': 'WELCOME20 - Flat 20% off for new users'},
    {'code': 'FREESHIP', 'fullText': 'FREESHIP - Free shipping on orders above ₹500'},
    {'code': 'FLAT50', 'fullText': 'FLAT50 - Flat ₹50 off on minimum order of ₹300'},
  ];

  // Static profile data
  final Map<String, dynamic> _dummyProfile = {
    'email': 'john.doe@example.com',
    'firstName': 'John',
    'lastName': 'Doe',
    'phone': '9876543210',
    'address': '123, Main Street, Sector 12',
    'city': 'Mumbai',
    'state': 'Maharashtra',
    'country': 'India',
    'pincode': '400001',
  };

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Set mobile number
    _phoneController.text = '9876543210';

    // Load profile data
    _fillFormWithProfile();

    // Print cart data
    final currentCart = widget.cartData ?? _dummyCartData;
    if (currentCart['items'] != null) {
      print('Cart Product Variant IDs:');
      for (var item in currentCart['items']) {
        print('Product: ${item['title']} - VariantID: ${item['variantId']}');
      }
    }
  }

  void _fillFormWithProfile() {
    _nameController.text = _dummyProfile['firstName'] ?? '';
    _lastnameController.text = _dummyProfile['lastName'] ?? '';
    _phoneController.text = _dummyProfile['phone'] ?? '';
    _emailController.text = _dummyProfile['email'] ?? '';
    _addressController.text = _dummyProfile['address'] ?? '';
    _address2Controller.text = '';
    _cityController.text = _dummyProfile['city'] ?? '';
    _provinceController.text = _dummyProfile['state'] ?? '';
    _pincodeController.text = _dummyProfile['pincode'] ?? '';

    print('CheckoutScreen Dummy Profile:');
    print('Email: ${_dummyProfile['email']}');
    print('FirstName: ${_dummyProfile['firstName']}');
    print('LastName: ${_dummyProfile['lastName']}');
    print('Phone: ${_dummyProfile['phone']}');
    print('Address: ${_dummyProfile['address']}');
    print('City: ${_dummyProfile['city']}');
    print('State: ${_dummyProfile['state']}');
    print('Country: ${_dummyProfile['country']}');
    print('Pincode: ${_dummyProfile['pincode']}');
  }

  void _clearForm() {
    _nameController.clear();
    _lastnameController.clear();
    _addressController.clear();
    _address2Controller.clear();
    _cityController.clear();
    _provinceController.clear();
    _pincodeController.clear();
    _emailController.text = _dummyProfile['email'] ?? '';
    _phoneController.text = '9876543210';
  }

  void _copyCouponCode(String code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon "$code" copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  double get _totalAmount {
    if (widget.totalAmount != null) {
      return widget.totalAmount!;
    }
    double total = 0;
    final currentCart = widget.cartData ?? _dummyCartData;
    for (var item in currentCart['items'] ?? []) {
      final price = item['price'];
      final quantity = item['quantity'];
      double itemPrice = 0.0;
      if (price is num) {
        itemPrice = price.toDouble();
      } else if (price is String) {
        itemPrice = double.tryParse(price) ?? 0.0;
      }
      int itemQty = 0;
      if (quantity is num) {
        itemQty = quantity.toInt();
      } else if (quantity is String) {
        itemQty = int.tryParse(quantity) ?? 0;
      }
      total += itemPrice * itemQty;
    }
    return total;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _addressController.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _provinceController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontSize: isLargeScreen ? 28 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen ? 24.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shipping Address',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 15 : 10),
                  Column(
                    children: [
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _useStoredAddress,
                            onChanged: (value) {
                              setState(() {
                                _useStoredAddress = value!;
                                if (_useStoredAddress) {
                                  _fillFormWithProfile();
                                } else {
                                  _clearForm();
                                }
                              });
                            },
                            activeColor: const Color.fromRGBO(111, 10, 15, 1),
                          ),
                          const Text('Use Saved Address',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Row(
                        children: [
                          Radio<bool>(
                            value: false,
                            groupValue: _useStoredAddress,
                            onChanged: (value) {
                              setState(() {
                                _useStoredAddress = value!;
                                if (!_useStoredAddress) {
                                  _clearForm();
                                }
                              });
                            },
                            activeColor: const Color.fromRGBO(111, 10, 15, 1),
                          ),
                          const Text('Enter New Address',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(_nameController, 'First Name'),
                          SizedBox(height: isLargeScreen ? 16 : 12),
                          _buildTextField(_lastnameController, 'Last Name'),
                          SizedBox(height: isLargeScreen ? 16 : 12),
                          _buildTextField(_emailController, 'Email',
                              keyboardType: TextInputType.emailAddress),
                          SizedBox(height: isLargeScreen ? 16 : 12),
                          _buildTextField(_addressController, 'Address'),
                          SizedBox(height: isLargeScreen ? 16 : 12),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child:
                                  _buildTextField(_cityController, 'City'),
                                ),
                              ),
                              SizedBox(width: isLargeScreen ? 16 : 8),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: _buildTextField(
                                      _pincodeController, 'Pincode',
                                      keyboardType: TextInputType.number),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isLargeScreen ? 16 : 12),
                          _buildRowFields(
                            context,
                            [
                              _buildTextField(_provinceController, 'State'),
                              _buildTextField(_phoneController, 'Phone Number',
                                  keyboardType: TextInputType.phone),
                            ],
                            isLargeScreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 30 : 20),
                  Text(
                    'Coupon Codes',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 15 : 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              setState(() {
                                _showCouponField = !_showCouponField;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _showCouponField,
                                    onChanged: (value) {
                                      setState(() {
                                        _showCouponField = value!;
                                      });
                                    },
                                    activeColor: const Color.fromRGBO(111, 10, 15, 1),
                                    checkColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Text(
                                    'Show Available Coupons',
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: EdgeInsets.only(
                              left: isLargeScreen ? 16 : 12,
                              right: isLargeScreen ? 16 : 12,
                              bottom: isLargeScreen ? 16 : 12,
                            ),
                            child: _dummyCouponCodes.isEmpty
                                ? Text(
                              'No coupons available',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isLargeScreen ? 16 : 14,
                              ),
                            )
                                : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _dummyCouponCodes.length,
                              itemBuilder: (context, index) {
                                final coupon = _dummyCouponCodes[index];
                                final code = coupon['code']!;
                                final fullText = coupon['fullText']!;
                                return Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fullText,
                                      style: TextStyle(
                                        fontSize: isLargeScreen
                                            ? 16
                                            : 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                        height: isLargeScreen
                                            ? 8
                                            : 4),
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: isLargeScreen
                                              ? 12
                                              : 8),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: isLargeScreen
                                              ? 12
                                              : 8,
                                          vertical: isLargeScreen
                                              ? 8
                                              : 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey[200]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              code,
                                              style: TextStyle(
                                                fontSize:
                                                isLargeScreen
                                                    ? 16
                                                    : 14,
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                color: Colors
                                                    .grey[800],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: isLargeScreen
                                                  ? 16
                                                  : 8),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _copyCouponCode(
                                                    code),
                                            style: ElevatedButton
                                                .styleFrom(
                                              backgroundColor:
                                              const Color.fromRGBO(
                                                  111,
                                                  10,
                                                  15,
                                                  1),
                                              shape:
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    8),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.copy,
                                              color: Colors.white,
                                              size: isLargeScreen
                                                  ? 20
                                                  : 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          crossFadeState: _showCouponField
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 30 : 20),
                  Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 15 : 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (widget.cartData ?? _dummyCartData)['items']?.length ?? 0,
                    itemBuilder: (context, index) {
                      var item = (widget.cartData ?? _dummyCartData)['items'][index];
                      return _buildOrderItem(item, isLargeScreen);
                    },
                  ),
                  SizedBox(height: isLargeScreen ? 30 : 20),
                  Container(
                    padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount:',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 20 : 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              '₹${_totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 28 : 24,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromRGBO(111, 10, 15, 1),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isLargeScreen ? 25 : 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _placeOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color.fromRGBO(111, 10, 15, 1),
                              minimumSize: Size(
                                  double.infinity, isLargeScreen ? 60 : 56),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            child: _isProcessing
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : Text(
                              'Place Order',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isLargeScreen ? 20 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixText: label == 'Phone Number' ? '+91 ' : null,
        prefixStyle: label == 'Phone Number'
            ? const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        )
            : null,
      ),
      keyboardType: keyboardType,
      validator: isRequired
          ? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (label == 'Phone Number' && value.length != 10) {
          return 'Phone number must be 10 digits';
        }
        if (label == 'Email' &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                .hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      }
          : null,
      inputFormatters: label == 'Phone Number'
          ? [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ]
          : null,
    );
  }

  Widget _buildRowFields(
      BuildContext context, List<Widget> children, bool isLargeScreen) {
    return isLargeScreen
        ? Row(
      children: children
          .map((child) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: child,
        ),
      ))
          .toList(),
    )
        : Column(
      children: children
          .map((child) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: SizedBox(width: double.infinity, child: child),
      ))
          .toList(),
    );
  }

  Widget _buildOrderItem(dynamic item, bool isLargeScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['image'] ?? 'https://via.placeholder.com/150',
                width: isLargeScreen ? 120 : 100,
                height: isLargeScreen ? 120 : 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: isLargeScreen ? 120 : 100,
                    height: isLargeScreen ? 120 : 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: isLargeScreen ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? 'Unknown Product',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isLargeScreen ? 6 : 4),
                  Text(
                    'Weight: ${item['weight']}',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 6 : 4),
                  Text(
                    'Quantity: ${item['quantity']}',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 10 : 8),
                  Text(
                    '₹${item['price']}',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 18,
                      color: const Color.fromRGBO(111, 10, 15, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully! (Demo)'),
            backgroundColor: Color.fromRGBO(111, 10, 15, 1),
          ),
        );
        setState(() {
          _isProcessing = false;
        });

        // Show a success dialog (optional)
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Order Placed!'),
            content: const Text('Your order has been placed successfully. (Demo Version)'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}