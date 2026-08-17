import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product/product_response_model.dart';
import '../../pages/auth/login.dart';
import '../../pages/products/product_detail_screen.dart';

class ProductCard extends StatefulWidget {
  final dynamic product;
  final bool isInitiallyInWishlist;

  const ProductCard({
    super.key,
    required this.product,
    this.isInitiallyInWishlist = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  bool _isInWishlist = false;
  bool _isAddingToWishlist = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  double _rating = 0.0;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    _isInWishlist = widget.isInitiallyInWishlist;
    _parseRating();
  }

  void _parseRating() {
    if (widget.product is ProductModel) {
      final p = widget.product as ProductModel;
      _rating = p.avgRating;
      _reviewCount = p.totalReviews;
    } else if (widget.product['metafields'] != null) {
      final metafields = widget.product['metafields'];
      if (metafields is Map) {
        final ratingData = metafields['reviews.rating'];
        final countData = metafields['reviews.rating_count'];
        if (ratingData != null) {
          try {
            final parsedRating = json.decode(ratingData.toString());
            _rating = double.parse(parsedRating['value'] ?? '0.0');
          } catch (_) {}
        }
        if (countData != null) {
          try {
            _reviewCount = int.parse(countData.toString());
          } catch (_) {}
        }
      }
    }
  }

  String _productId() {
    if (widget.product is ProductModel) {
      return (widget.product as ProductModel).id.split('/').last;
    }
    return widget.product['id']?.toString().split('/').last ?? '';
  }

  String _productTitle() {
    if (widget.product is ProductModel) {
      return (widget.product as ProductModel).title;
    }
    return widget.product['title']?.toString() ?? 'No Title';
  }

  Future<void> toggleWishlist(BuildContext context) async {
    if (_isAddingToWishlist) return;
    final productId = _productId();

    setState(() {
      _isInWishlist = !_isInWishlist;
      _isAddingToWishlist = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id');
      if (customerId == null) {
        setState(() {
          _isInWishlist = false;
          _isAddingToWishlist = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to manage wishlist'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        });
        return;
      }

      http.Response response;
      if (_isInWishlist) {
        response = await http.post(
          Uri.parse('https://new-test.megascale.co.in/api/p1/addtowishlist'),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'Keep-Alive',
          },
          body: json.encode({'customer_id': customerId, 'product_id': productId}),
        ).timeout(const Duration(seconds: 30));
      } else {
        response = await http.delete(
          Uri.parse('https://new-test.megascale.co.in/api/p1/removewishlist'),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'Keep-Alive',
          },
          body: json.encode({'customer_id': customerId, 'product_id': productId}),
        ).timeout(const Duration(seconds: 30));
      }

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isInWishlist ? 'Added to wishlist' : 'Removed from wishlist'),
            backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        setState(() => _isInWishlist = !_isInWishlist);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update wishlist'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() => _isInWishlist = !_isInWishlist);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating wishlist'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    } finally {
      setState(() => _isAddingToWishlist = false);
    }
  }

  Widget _buildStarRating(double rating, {double size = 12}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: List.generate(5, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, color: Colors.amber, size: size);
          } else if (index < rating && rating % 1 != 0) {
            return Icon(Icons.star_half, color: Colors.amber, size: size);
          } else {
            return Icon(Icons.star_border, color: Colors.grey, size: size);
          }
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double fontSize = MediaQuery.of(context).size.width * 0.035;

    // Pricing & image extraction helper
    String? priceAmount;
    String? compareAtAmount;
    String? displayImgUrl;

    if (widget.product is ProductModel) {
      final p = widget.product as ProductModel;
      if (p.variants.isNotEmpty) {
        priceAmount = p.variants[0].price.amount;
        compareAtAmount = p.variants[0].compareAtPrice?.amount;
      }
      if (p.images.isNotEmpty) {
        displayImgUrl = p.images[0].url;
      } else {
        displayImgUrl = p.imageUrl;
      }
    } else {
      final variants = widget.product['variants'] as List<dynamic>? ?? [];
      final firstVariant = variants.isNotEmpty ? variants[0] : null;
      if (firstVariant != null) {
        priceAmount = firstVariant['price']?.toString() ?? firstVariant['price']?['amount']?.toString();
        compareAtAmount = firstVariant['compareAtPrice']?.toString() ?? firstVariant['compareAtPrice']?['amount']?.toString();
      }
      final images = widget.product['media']?.isNotEmpty == true
          ? widget.product['media']
          : widget.product['images'] ?? [];
      if (images.isNotEmpty) {
        displayImgUrl = images[0]['previewSrc']?.toString() ?? images[0]['src']?.toString();
      }
    }

    final double price = double.tryParse(priceAmount ?? '0.0') ?? 0.0;
    final double compareAtPrice = double.tryParse(compareAtAmount ?? '0.0') ?? 0.0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: widget.product),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'product-${_productId()}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        displayImgUrl ?? 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _productTitle(),
                        style: TextStyle(
                          fontSize: fontSize - 2,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            price > 0 ? '₹${price.toInt()}' : 'Price-',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: const Color.fromRGBO(111, 10, 15, 1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (compareAtPrice > price) ...[
                            const SizedBox(width: 4),
                            Text(
                              '₹${compareAtPrice.toInt()}',
                              style: TextStyle(
                                fontSize: fontSize - 4,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${((compareAtPrice - price) / compareAtPrice * 100).toStringAsFixed(0)}% OFF',
                                style: TextStyle(
                                  fontSize: fontSize - 4,
                                  color: const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStarRating(_rating, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '($_reviewCount)',
                            style: TextStyle(fontSize: fontSize - 4, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => toggleWishlist(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                    ],
                  ),
                  child: _isAddingToWishlist
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(111, 10, 15, 1)),
                          ),
                        )
                      : Icon(
                          _isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: _isInWishlist ? const Color.fromRGBO(111, 10, 15, 1) : Colors.grey[600],
                          size: 16,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
