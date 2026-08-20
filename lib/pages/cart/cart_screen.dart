import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/product/product_response_model.dart';
import '../../providers/cart/cart_provider.dart';
import '../../providers/product/product_provider.dart';
import '../checkout/checkout_screen.dart';
import '../products/product_detail_screen.dart';
import '../auth/login.dart';

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
                            final customerId = prefs.getString('customer_id');

                            if (!mounted) return;

                            if (customerId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please login to checkout')),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              );
                              return;
                            }

                            // Check if cart has items
                            if (cartProvider.items.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Your cart is empty'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Navigate to CheckoutScreen with cart data and total
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
}
