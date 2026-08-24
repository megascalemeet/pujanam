import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/product/product_response_model.dart';
import '../../providers/cart/cart_provider.dart';
import '../../providers/product/product_provider.dart';
import '../checkout/checkout_screen.dart';
import '../products/product_detail_screen.dart';
import '../../providers/auth/auth_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Timer? _timer;
  int _currentProductIndex = 0;
  List<ProductModel> _displayedProducts = [];
  final Color primaryColor = const Color.fromRGBO(111, 10, 15, 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).fetchAndUpdateFromSession();
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (productProvider.products.isEmpty) {
        productProvider.loadInitialProducts().then((_) {
          _updateDisplayedProducts(productProvider.products);
          _startProductRotation(productProvider.products);
        });
      } else {
        _updateDisplayedProducts(productProvider.products);
        _startProductRotation(productProvider.products);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startProductRotation(List<ProductModel> products) {
    _timer?.cancel();
    if (products.isEmpty) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (products.isNotEmpty && mounted) {
        setState(() {
          _currentProductIndex = (_currentProductIndex + 3) % products.length;
          _updateDisplayedProducts(products);
        });
      }
    });
  }

  void _updateDisplayedProducts(List<ProductModel> products) {
    if (products.isEmpty) {
      _displayedProducts = [];
      return;
    }
    int startIndex = _currentProductIndex;
    int endIndex = (startIndex + 3) % products.length;
    if (endIndex > startIndex) {
      _displayedProducts = products.sublist(startIndex, endIndex);
    } else {
      _displayedProducts = [
        ...products.sublist(startIndex),
        ...products.sublist(0, endIndex),
      ];
    }
  }

  Widget _buildStarRating(double rating, {double size = 14}) {
    int fullStars = rating.floor();
    double remainder = rating - fullStars;
    List<Widget> stars = [];

    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, color: Colors.amber, size: size));
    }
    if (remainder >= 0.5) {
      stars.add(Icon(Icons.star_half, color: Colors.amber, size: size));
    }
    int emptyStars = 5 - stars.length;
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(Icons.star_border, color: Colors.amber, size: size));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45;
    final cardHeight = screenWidth * 0.6;

    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text(
          'Shopping Cart',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      ),
      body: cartProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (cartProvider.items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.shopping_cart_outlined,
                                      size: 64, color: primaryColor),
                                ),
                                const SizedBox(height: 16),
                                Text('Your cart is empty',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800])),
                                const SizedBox(height: 8),
                                Text('Add items to start shopping',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey[600])),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: cartProvider.items.length,
                            itemBuilder: (context, index) {
                              final item = cartProvider.items[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withValues(alpha: 0.1),
                                        spreadRadius: 1,
                                        blurRadius: 10,
                                        offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: item.imageUrl.isNotEmpty
                                            ? Image.network(
                                                item.imageUrl,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  width: 100,
                                                  height: 100,
                                                  color: Colors.grey[200],
                                                  child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                                                ),
                                              )
                                            : Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey[200],
                                                child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                                              ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[800]),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text('Weight: ${item.weight}',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600])),
                                            const SizedBox(height: 8),
                                            Text(
                                              '₹${item.price}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius: BorderRadius.circular(8)),
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.remove, size: 20, color: primaryColor),
                                                        onPressed: () async {
                                                          await cartProvider.updateQuantityAndSync(
                                                            item.productId,
                                                            item.weight,
                                                            item.quantity - 1,
                                                          );
                                                        },
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                                        child: Text(
                                                            item.quantity.toString(),
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold)),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.add, size: 20, color: primaryColor),
                                                        onPressed: () async {
                                                          await cartProvider.updateQuantityAndSync(
                                                            item.productId,
                                                            item.weight,
                                                            item.quantity + 1,
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 24),
                                                  onPressed: () async {
                                                    await cartProvider.removeItemAndSync(item.productId, item.weight);
                                                  },
                                                ),
                                              ],
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
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explore Products',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800]),
                              ),
                              const SizedBox(height: 16),
                              _displayedProducts.isEmpty
                                  ? Center(
                                      child: Text('No products available',
                                          style: TextStyle(fontSize: 16, color: Colors.grey[600])))
                                  : SizedBox(
                                      height: cardHeight,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _displayedProducts.length,
                                        itemBuilder: (context, index) {
                                          final product = _displayedProducts[index];
                                          final String imageUrl = product.imageUrl.isNotEmpty
                                              ? product.imageUrl
                                              : (product.images.isNotEmpty ? product.images[0].url : 'https://via.placeholder.com/150');
                                          final double price = product.priceRange != null
                                              ? double.tryParse(product.priceRange!.minVariantPrice.amount) ?? 0.0
                                              : 0.0;

                                          return GestureDetector(
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ProductDetailScreen(product: product),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: cardWidth,
                                              margin: const EdgeInsets.only(right: 16),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withValues(alpha: 0.1),
                                                    spreadRadius: 1,
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: Image.network(
                                                      imageUrl,
                                                      width: double.infinity,
                                                      height: cardHeight * 0.55,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => Container(
                                                        width: double.infinity,
                                                        height: cardHeight * 0.55,
                                                        color: Colors.grey[200],
                                                        child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const SizedBox(height: 8),
                                                        Text(
                                                          product.title,
                                                          style: TextStyle(
                                                            fontSize: screenWidth < 400 ? 12 : 14,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.grey[800],
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            _buildStarRating(product.avgRating,
                                                                size: screenWidth < 400 ? 10 : 12),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              '${product.avgRating.toStringAsFixed(2)} / 5 (${product.totalReviews})',
                                                              style: TextStyle(
                                                                fontSize: screenWidth < 400 ? 10 : 12,
                                                                color: Colors.grey[600],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          '₹${price.toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: primaryColor,
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
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (cartProvider.items.isNotEmpty)
                  Container(
                    padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 30,),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, -5)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                            Text('₹${cartProvider.subtotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final platformToken = prefs.getString('platformToken') ?? '';
                            if (platformToken.isEmpty) {
                              if (!context.mounted) return;
                              final loggedIn = await _showLoginDialog(context);
                              if (!context.mounted) return;
                              if (!loggedIn) return;
                            }

                            // Check if cart has items
                            if (cartProvider.items.isEmpty) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Your cart is empty'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                              return;
                            }

                            // Navigate to CheckoutScreen with cart data and total
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutScreen(
                                    cartData: {
                                      'items': cartProvider.items.map((item) => {
                                        'title': item.title,
                                        'weight': item.weight,
                                        'quantity': item.quantity,
                                        'price': item.price,
                                        'image': item.imageUrl,
                                        'variantId': item.variantId,
                                      }).toList(),
                                    },
                                    totalAmount: cartProvider.subtotal,
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: const Text('Proceed to Checkout',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Future<bool> _showLoginDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _CheckoutLoginDialog(primaryColor: primaryColor);
      },
    );
    return result ?? false;
  }
}

class _CheckoutLoginDialog extends StatefulWidget {
  final Color primaryColor;
  const _CheckoutLoginDialog({required this.primaryColor});

  @override
  State<_CheckoutLoginDialog> createState() => _CheckoutLoginDialogState();
}

class _CheckoutLoginDialogState extends State<_CheckoutLoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _resendCooldown = 60; // 60 seconds cooldown
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendCheckoutOtp('+91${_mobileController.text}');

    setState(() {
      _isLoading = false;
    });

    if (success) {
      setState(() {
        _isOtpSent = true;
      });
      _startCooldown();
    } else {
      setState(() {
        _errorMessage = authProvider.errorMessage ?? 'Failed to send OTP';
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = 'OTP must be 6 digits';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyCheckoutOtp(
      '+91${_mobileController.text}',
      _otpController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      setState(() {
        _errorMessage = authProvider.errorMessage ?? 'Invalid OTP';
      });
      _otpController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isOtpSent ? 'Verify OTP' : 'Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[700], fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (!_isOtpSent) ...[
                  Text(
                    'Enter your WhatsApp mobile number to receive verification code.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      prefixText: '+91 ',
                      labelText: 'WhatsApp Mobile Number',
                      hintText: '10-digit number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number';
                      }
                      if (value.length != 10) {
                        return 'Mobile number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Send OTP',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ] else ...[
                  Text(
                    'Enter the 6-digit verification code sent to WhatsApp number +91 ${_mobileController.text}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Verification Code',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isOtpSent = false;
                            _otpController.clear();
                            _errorMessage = null;
                          });
                        },
                        child: const Text('Change Number'),
                      ),
                      TextButton(
                        onPressed: _resendCooldown > 0 || _isLoading ? null : _sendOtp,
                        child: Text(
                          _resendCooldown > 0 ? 'Resend in ${_resendCooldown}s' : 'Resend OTP',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Verify & Proceed',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
