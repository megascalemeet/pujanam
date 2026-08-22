import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/checkout/checkout_provider.dart';
import '../../providers/customer/customer_provider.dart';
import '../payment/payment_options_screen.dart';

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
  bool _showCouponSection = false;

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
  final TextEditingController _couponController = TextEditingController();

  static const Color _primaryColor = Color.fromRGBO(111, 10, 15, 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CheckoutProvider>(context, listen: false).fetchCoupons();
    });
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
    _couponController.dispose();
    super.dispose();
  }

  void _fillFormWithProfile() {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final profile = customerProvider.profile;
    final address = customerProvider.addresses.isNotEmpty
        ? customerProvider.addresses.first
        : null;

    _nameController.text = address?.firstName ?? '';
    _lastnameController.text = address?.lastName ?? '';
    _phoneController.text = address?.phoneNumber ?? '';
    _emailController.text = profile?.email ?? '';
    _addressController.text = address?.addressLine1 ?? '';
    _address2Controller.text = address?.addressLine2 ?? '';
    _cityController.text = address?.city ?? '';
    _provinceController.text = address?.state ?? '';
    _stateController.text = address?.state ?? '';
    _pincodeController.text = address?.postalCode ?? '';
  }

  void _clearForm() {
    _nameController.clear();
    _lastnameController.clear();
    _addressController.clear();
    _address2Controller.clear();
    _cityController.clear();
    _provinceController.clear();
    _stateController.clear();
    _pincodeController.clear();

    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final profile = customerProvider.profile;
    _emailController.text = profile?.email ?? '';
    _phoneController.text = profile?.phoneNumber ?? '';
  }

  double get _totalAmount {
    if (widget.totalAmount != null) return widget.totalAmount!;
    double total = 0;
    for (var item in (widget.cartData ?? const {})['items'] ?? []) {
      final price = item['price'];
      final quantity = item['quantity'];
      double itemPrice = price is num ? price.toDouble() : (double.tryParse(price?.toString() ?? '') ?? 0.0);
      int itemQty = quantity is num ? quantity.toInt() : (int.tryParse(quantity?.toString() ?? '') ?? 0);
      total += itemPrice * itemQty;
    }
    return total;
  }

  void _showSnack(String message, {Color color = Colors.red}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    final checkoutProvider =
        Provider.of<CheckoutProvider>(context, listen: false);
    final success = await checkoutProvider.applyCoupon(code);
    if (mounted) {
      if (success) {
        _couponController.clear();
        _showSnack(
            checkoutProvider.couponSuccess ?? 'Coupon applied!',
            color: Colors.green);
      } else {
        _showSnack(checkoutProvider.couponError ?? 'Invalid coupon code.');
      }
    }
  }

  Future<void> _removeCoupon() async {
    final checkoutProvider =
        Provider.of<CheckoutProvider>(context, listen: false);
    await checkoutProvider.removeCoupon();
    if (mounted) {
      _showSnack('Coupon removed.', color: Colors.grey[700]!);
    }
  }

  void _applyListedCoupon(String code) {
    _couponController.text = code;
    _applyCoupon();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final checkoutProvider =
        Provider.of<CheckoutProvider>(context, listen: false);
    final addressData = {
      "addressType": "shipping",
      "address1": _addressController.text.trim(),
      "city": _cityController.text.trim(),
      "province": _provinceController.text.trim(),
      "country": "India",
      "zip": _pincodeController.text.trim(),
      "firstName": _nameController.text.trim(),
      "lastName": _lastnameController.text.trim(),
      "phone": _phoneController.text.trim(),
      "saveToUserAddresses": !_useStoredAddress,
    };

    final success = await checkoutProvider.addAddressToCheckout(addressData);

    if (!mounted) return;

    if (!success) {
      _showSnack(
          checkoutProvider.errorMessage ?? 'Could not save your address. Please try again.');
      setState(() => _isProcessing = false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString('checkout_session_token') ?? '';

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (sessionToken.isEmpty) {
      _showSnack('Your cart session has expired. Please add items and try again.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentOptionsScreen(sessionToken: sessionToken),
      ),
    );
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
        backgroundColor: _primaryColor,
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
                  // ─── Shipping Address ────────────────────────────────────
                  Text(
                    'Shipping Address',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 10 : 8),
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
                        activeColor: _primaryColor,
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
                            if (!_useStoredAddress) _clearForm();
                          });
                        },
                        activeColor: _primaryColor,
                      ),
                      const Text('Enter New Address',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                              _buildTextField(
                                  _phoneController, 'Phone Number',
                                  keyboardType: TextInputType.phone),
                            ],
                            isLargeScreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 30 : 20),

                  // ─── Apply Coupon ────────────────────────────────────────
                  _buildCouponSection(isLargeScreen),
                  SizedBox(height: isLargeScreen ? 30 : 20),

                  // ─── Order Summary ───────────────────────────────────────
                  Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 15 : 10),
                  if ((widget.cartData?['items'] as List?)?.isNotEmpty ?? false)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          (widget.cartData?['items'] as List?)?.length ?? 0,
                      itemBuilder: (context, index) {
                        var item =
                            (widget.cartData!['items'] as List)[index];
                        return _buildOrderItem(item, isLargeScreen);
                      },
                    ),
                  SizedBox(height: isLargeScreen ? 30 : 20),

                  // ─── Total + Place Order ─────────────────────────────────
                  Container(
                    padding: EdgeInsets.all(isLargeScreen ? 24 : 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Consumer<CheckoutProvider>(
                      builder: (context, cp, _) {
                        final discount = cp.discountAmount;
                        final displayTotal = _totalAmount - discount;
                        return Column(
                          children: [
                            if (discount > 0) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Subtotal:',
                                      style: TextStyle(
                                          fontSize: isLargeScreen ? 16 : 14,
                                          color: Colors.grey[600])),
                                  Text(
                                    '₹${_totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: isLargeScreen ? 18 : 16,
                                        color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Coupon Discount:',
                                      style: TextStyle(
                                          fontSize: isLargeScreen ? 16 : 14,
                                          color: Colors.green[700])),
                                  Text(
                                    '-₹${discount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: isLargeScreen ? 18 : 16,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Amount:',
                                    style: TextStyle(
                                        fontSize: isLargeScreen ? 20 : 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800])),
                                Text(
                                  '₹${(displayTotal > 0 ? displayTotal : _totalAmount).toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: isLargeScreen ? 28 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryColor),
                                ),
                              ],
                            ),
                            SizedBox(height: isLargeScreen ? 25 : 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isProcessing ? null : _placeOrder,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryColor,
                                  minimumSize: Size(
                                      double.infinity,
                                      isLargeScreen ? 60 : 56),
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
                        );
                      },
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

  // ─── Coupon Section ──────────────────────────────────────────────────────
  Widget _buildCouponSection(bool isLargeScreen) {
    return Consumer<CheckoutProvider>(
      builder: (context, cp, _) {
        return Container(
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
              // ── Header row ──
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    setState(() => _showCouponSection = !_showCouponSection);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? 20 : 16,
                        vertical: isLargeScreen ? 16 : 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.local_offer_outlined,
                              color: _primaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Apply Coupon',
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 16 : 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[800],
                                ),
                              ),
                              if (cp.hasCouponApplied)
                                Text(
                                  '${cp.appliedCouponCode} applied',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                        ),
                        if (cp.hasCouponApplied)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'APPLIED',
                              style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          Icon(
                            _showCouponSection
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey[500],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Applied coupon chip ──
              if (cp.hasCouponApplied)
                Padding(
                  padding: EdgeInsets.only(
                    left: isLargeScreen ? 20 : 16,
                    right: isLargeScreen ? 20 : 16,
                    bottom: 14,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${cp.appliedCouponCode} applied successfully!',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        GestureDetector(
                          onTap: cp.isCouponLoading ? null : _removeCoupon,
                          child: cp.isCouponLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.green))
                              : const Icon(Icons.close,
                                  color: Colors.green, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Expandable panel ──
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: EdgeInsets.only(
                    left: isLargeScreen ? 20 : 16,
                    right: isLargeScreen ? 20 : 16,
                    bottom: isLargeScreen ? 20 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _couponController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Enter coupon code',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: _primaryColor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed:
                                  cp.isCouponLoading ? null : _applyCoupon,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                              ),
                              child: cp.isCouponLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Text('Apply',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Available coupons list
                      if (cp.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                                color: _primaryColor),
                          ),
                        )
                      else if (cp.coupons.isNotEmpty) ...[
                        Text(
                          'Available Coupons',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...cp.coupons.map((coupon) =>
                            _buildCouponCard(coupon, cp, isLargeScreen)),
                      ],
                    ],
                  ),
                ),
                crossFadeState: _showCouponSection
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCouponCard(
      dynamic coupon, CheckoutProvider cp, bool isLargeScreen) {
    final code = coupon.code as String;
    final name = coupon.name as String;
    final isAlreadyApplied = cp.appliedCouponCode == code;

    String discountLabel = name;
    if (coupon.discountType == 'percentage') {
      discountLabel = '${coupon.value}% OFF';
    } else if (coupon.discountType == 'fixed') {
      discountLabel = '₹${coupon.value} OFF';
    }

    String subtitleText = name;
    if (coupon.minOrderAmount != null) {
      subtitleText += ' • Min order ₹${coupon.minOrderAmount}';
    }

    final double orderTotal = _totalAmount;
    final bool isEligible = coupon.minOrderAmount == null || orderTotal >= coupon.minOrderAmount!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAlreadyApplied 
            ? Colors.green[50] 
            : (isEligible ? Colors.grey[50] : Colors.red[50]?.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAlreadyApplied 
              ? Colors.green[300]! 
              : (isEligible ? Colors.grey[200]! : Colors.red[100]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      code,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isAlreadyApplied 
                            ? Colors.green[700] 
                            : (isEligible ? Colors.black : Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isEligible 
                            ? _primaryColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        discountLabel,
                        style: TextStyle(
                            fontSize: 11,
                            color: isEligible ? _primaryColor : Colors.grey[600],
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleText,
                  style: TextStyle(
                    fontSize: 12, 
                    color: isEligible ? Colors.grey[600] : Colors.red[700],
                    fontWeight: isEligible ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
                if (!isEligible) ...[
                  const SizedBox(height: 2),
                  Text(
                    'This coupon is only available on ₹${coupon.minOrderAmount} or above amount',
                    style: TextStyle(fontSize: 11, color: Colors.red[600], fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isAlreadyApplied)
            TextButton(
              onPressed: cp.isCouponLoading ? null : _removeCoupon,
              child: const Text('Remove',
                  style: TextStyle(color: Colors.red, fontSize: 13)),
            )
          else
            OutlinedButton(
              onPressed: (!isEligible || cp.isCouponLoading)
                  ? null
                  : () => _applyListedCoupon(code),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isEligible ? _primaryColor : Colors.grey[300]!,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Apply',
                  style: TextStyle(
                      color: isEligible ? _primaryColor : Colors.grey[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
        ],
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
                item['image'] ?? '',
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
                      color: _primaryColor,
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
}