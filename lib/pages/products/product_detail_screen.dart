import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/cart/cart_models.dart';
import '../../models/category/category_product_response_model.dart';
import '../../models/product/product_detail_response_model.dart';
import '../../models/product/product_response_model.dart';
import '../../providers/cart/cart_provider.dart';
import '../../services/notification_services.dart';
import '../../services/product/product_api_service.dart';
import '../../widgets/recent_purchase_notification.dart';
import '../auth/login.dart';
import '../cart/cart_screen.dart';
import 'product_list_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isAddingToCart = false;
  bool _isInWishlist = false;
  bool _isAddingToWishlist = false;
  String? _selectedWeight;
  String? _selectedPrice;
  String? _selectedMRP;
  int _cartCount = 0;
  bool _isLoading = true;
  int _currentReviewPage = 0;
  PageController? _imagePageController;
  int _currentImageIndex = 0;

  ProductDetailModel? _productDetails;
  List<ProductModel> _similarProducts = [];

  final ProductApiService _apiService = ProductApiService();

  String get productHandle {
    if (widget.product is ProductModel) {
      return (widget.product as ProductModel).handle;
    } else if (widget.product is ProductDetailModel) {
      return (widget.product as ProductDetailModel).handle;
    } else if (widget.product is CategoryProductModel) {
      return (widget.product as CategoryProductModel).handle;
    }
    return widget.product['handle']?.toString() ?? '';
  }

  String get productId {
    if (widget.product is ProductModel) {
      return (widget.product as ProductModel).id.split('/').last;
    } else if (widget.product is ProductDetailModel) {
      return (widget.product as ProductDetailModel).id.split('/').last;
    } else if (widget.product is CategoryProductModel) {
      return (widget.product as CategoryProductModel).id.split('/').last;
    }
    return widget.product['id']?.toString().split('/').last ?? '';
  }

  String get productTitle {
    if (widget.product is ProductModel) {
      return (widget.product as ProductModel).title;
    } else if (widget.product is ProductDetailModel) {
      return (widget.product as ProductDetailModel).title;
    } else if (widget.product is CategoryProductModel) {
      return (widget.product as CategoryProductModel).title;
    }
    return widget.product['title']?.toString() ?? 'Product Details';
  }

  String get productDescription {
    if (widget.product is ProductModel) {
      return (widget.product as ProductModel).description;
    } else if (widget.product is ProductDetailModel) {
      return (widget.product as ProductDetailModel).description;
    } else if (widget.product is CategoryProductModel) {
      return (widget.product as CategoryProductModel).description;
    }
    return widget.product['description']?.toString() ?? '';
  }

  List<dynamic> get productInitialImages {
    if (widget.product is ProductModel) {
      return (widget.product as ProductModel).images;
    } else if (widget.product is ProductDetailModel) {
      return (widget.product as ProductDetailModel).images;
    } else if (widget.product is CategoryProductModel) {
      return (widget.product as CategoryProductModel).images;
    }
    return widget.product['media'] ?? widget.product['images'] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    _currentReviewPage = 0;

    checkWishlistStatus();
    _loadCartCount();
    _loadAllDetails();
  }

  Future<void> _loadAllDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final detailResponse = await _apiService.fetchProductDetail(
        productHandle,
      );
      _productDetails = detailResponse.data;

      // Initialize variant pricing
      if (_productDetails != null && _productDetails!.variants.isNotEmpty) {
        final firstVariant = _productDetails!.variants[0];
        _selectedWeight = firstVariant.title;
        _selectedPrice = firstVariant.price.amount;
        _selectedMRP = firstVariant.compareAtPrice?.amount ?? _selectedPrice;
      }

      // Load You Might Also Like section (Limit 10 products)
      final listResponse = await _apiService.fetchProducts(page: 1, limit: 10);
      _similarProducts = listResponse.data
          .where((p) => p.id.split('/').last != productId)
          .toList();
    } catch (e) {
      debugPrint('Error loading product details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCartCount() async {
    try {
      if (mounted) {
        setState(() {
          _cartCount = Provider.of<CartProvider>(
            context,
            listen: false,
          ).items.length;
        });
      }
    } catch (e) {
      debugPrint('Error loading cart count: $e');
    }
  }

  Future<void> checkWishlistStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id');
      if (customerId == null) return;

      final response = await http
          .get(
            Uri.parse(
              'https://new-test.megascale.co.in/api/p1/wishlist?customer_id=$customerId',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> wishlistData = json.decode(response.body);
        final List<dynamic> wishlistItems = wishlistData['wishlist'] ?? [];
        final pId = productId;

        final bool isInList = wishlistItems.any(
          (item) =>
              item is Map<String, dynamic> &&
              item['product_id']?.toString() == pId,
        );

        if (mounted) {
          setState(() {
            _isInWishlist = isInList;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking wishlist: $e');
    }
  }

  Future<void> toggleWishlist(BuildContext context) async {
    if (_isAddingToWishlist) return;

    setState(() {
      _isInWishlist = !_isInWishlist;
      _isAddingToWishlist = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id');
      final pId = productId;

      if (customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to manage wishlist')),
        );
        setState(() {
          _isInWishlist = !_isInWishlist;
          _isAddingToWishlist = false;
        });
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
        response = await http
            .post(
              Uri.parse(
                'https://new-test.megascale.co.in/api/p1/addtowishlist',
              ),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'customer_id': customerId, 'product_id': pId}),
            )
            .timeout(const Duration(seconds: 30));
      } else {
        response = await http
            .delete(
              Uri.parse(
                'https://new-test.megascale.co.in/api/p1/removewishlist',
              ),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'customer_id': customerId, 'product_id': pId}),
            )
            .timeout(const Duration(seconds: 30));
      }

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isInWishlist ? 'Added to wishlist' : 'Removed from wishlist',
            ),
            backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        setState(() => _isInWishlist = !_isInWishlist);
      }
    } catch (e) {
      setState(() => _isInWishlist = !_isInWishlist);
    } finally {
      if (mounted) {
        setState(() => _isAddingToWishlist = false);
      }
    }
  }

  void _updatePrice(String? weight) {
    if (weight == null || _productDetails == null) return;
    final variants = _productDetails!.variants;
    if (variants.isEmpty) return;

    final selectedVariant = variants.firstWhere(
      (v) => v.title == weight,
      orElse: () => variants[0],
    );

    setState(() {
      _selectedWeight = weight;
      _selectedPrice = selectedVariant.price.amount;
      _selectedMRP = selectedVariant.compareAtPrice?.amount ?? _selectedPrice;
    });
  }

  double _calculateDiscount() {
    if (_selectedMRP == null || _selectedPrice == null) return 0;
    final double mrp = double.tryParse(_selectedMRP!) ?? 0;
    final double price = double.tryParse(_selectedPrice!) ?? 0;
    if (mrp == 0 || mrp == price) return 0;
    return ((mrp - price) / mrp * 100);
  }

  Future<void> _shareProductToWhatsApp() async {
    try {
      final handle = productHandle;
      final String shareUrl = "https://store.nilkanthdham.in/products/$handle";
      final text = "Check out this product: $shareUrl";
      final url = Uri.parse(
        'whatsapp://send?text=${Uri.encodeComponent(text)}',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        final webUrl = Uri.parse(
          'https://wa.me/?text=${Uri.encodeComponent(text)}',
        );
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open WhatsApp.')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error sharing to WhatsApp: $e');
    }
  }

  int _generateRandomViewingCount() {
    return 10 + (productId.hashCode % 41);
  }

  int _generateRandomSalesCount() {
    return 5 + (productId.hashCode % 15);
  }

  String _generateRandomTimePeriod() {
    final periods = ['4 hours', '12 hours', '24 hours', '2 days'];
    return periods[productId.hashCode % periods.length];
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromRGBO(111, 10, 15, 0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _productDetails?.title ?? productTitle,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
            if (_cartCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(111, 10, 15, 1),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$_cartCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductImage() {
    List<dynamic> images = [];
    if (_productDetails != null) {
      images = _productDetails!.images;
    } else {
      images = productInitialImages;
    }

    if (images.isEmpty) {
      images = [
        {'url': 'https://via.placeholder.com/150'},
      ];
    }

    final double discount = _calculateDiscount();

    return Container(
      height: 350,
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _imagePageController,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final img = images[index];
                final String imageUrl = img is Map
                    ? (img['previewSrc'] ??
                          img['src'] ??
                          img['url'] ??
                          'https://via.placeholder.com/150')
                    : img.url;

                return AnimatedBuilder(
                  animation: _imagePageController!,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_imagePageController!.position.haveDimensions) {
                      value = _imagePageController!.page != null
                          ? (_imagePageController!.page! - index).abs()
                          : 0.0;
                      value = (1 - (value * 0.3)).clamp(0.85, 1.0);
                    }
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Container(
                                color: Colors.grey[300],
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          color: const Color.fromRGBO(
                                            111,
                                            10,
                                            15,
                                            1,
                                          ),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.center,
                                      colors: [
                                        Colors.black.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (images.length > 1 && _currentImageIndex > 0)
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _imagePageController?.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          if (images.length > 1 && _currentImageIndex < images.length - 1)
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _imagePageController?.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          if (discount > 0)
            Positioned(
              left: 20,
              top: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${discount.toStringAsFixed(0)}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Positioned(
            right: 20,
            top: 20,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => toggleWishlist(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: _isAddingToWishlist
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(111, 10, 15, 1),
                              ),
                            ),
                          )
                        : Icon(
                            _isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isInWishlist
                                ? const Color.fromRGBO(111, 10, 15, 1)
                                : Colors.grey,
                            size: 24,
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _shareProductToWhatsApp,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentImageIndex ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentImageIndex
                          ? const Color.fromRGBO(111, 10, 15, 1)
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    if (_productDetails == null) return const SizedBox.shrink();
    final variants = _productDetails!.variants;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Quantity:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: variants.map<Widget>((variant) {
              final variantTitle = variant.title;
              final price = variant.price.amount;
              final mr = variant.compareAtPrice?.amount ?? price;
              final isSelected = _selectedWeight == variantTitle;

              final double mrpValue = double.tryParse(mr) ?? 0.0;
              final double priceValue = double.tryParse(price) ?? 0.0;
              final double savings = mrpValue - priceValue;
              final bool hasDiscount = savings > 0;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _updatePrice(variantTitle),
                  child: Container(
                    width: 110,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFF3E0)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFFA726)
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          variantTitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        if (hasDiscount)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '₹$mr',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E8),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '${((savings / mrpValue) * 100).toStringAsFixed(0)}% off',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (hasDiscount) const SizedBox(height: 4),
                        Text(
                          '₹$price',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(111, 10, 15, 1),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (savings > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA726),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Save ₹${savings.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRichText(String text) {
    List<InlineSpan> spans = [];
    final RegExp inlineExp = RegExp(
      r'<strong>(.*?)</strong>|<b>(.*?)</b>',
      caseSensitive: false,
      dotAll: true,
    );

    int lastIndex = 0;
    for (var match in inlineExp.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text
                .substring(lastIndex, match.start)
                .replaceAll(RegExp(r'<[^>]*>'), ''),
          ),
        );
      }
      String boldText = match.group(1) ?? match.group(2) ?? '';
      spans.add(
        TextSpan(
          text: boldText.replaceAll(RegExp(r'<[^>]*>'), ''),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex).replaceAll(RegExp(r'<[^>]*>'), ''),
        ),
      );
    }

    return Text.rich(
      TextSpan(
        children: spans,
        style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
      ),
    );
  }

  List<Widget> parseHtmlDescription(String html) {
    List<Widget> widgets = [];
    String cleaned = html
        .replaceAll('&nbsp;', ' ')
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n');

    final RegExp blockExp = RegExp(
      r'<(p|li)>(.*?)</\1>',
      caseSensitive: false,
      dotAll: true,
    );

    for (var match in blockExp.allMatches(cleaned)) {
      final tag = match.group(1)?.toLowerCase();
      final content = match.group(2) ?? '';
      if (content.trim().isEmpty) continue;

      if (tag == 'p') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildRichText(content),
          ),
        );
      } else if (tag == 'li') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 14, height: 1.4)),
                Expanded(child: _buildRichText(content)),
              ],
            ),
          ),
        );
      }
    }

    if (widgets.isEmpty) {
      widgets.add(_buildRichText(cleaned.replaceAll(RegExp(r'<[^>]*>'), '')));
    }

    return widgets;
  }

  Widget _buildDescription() {
    final String description =
        _productDetails?.description ?? productDescription;

    return Column(
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            title: const Text(
              'Description:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black54,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: parseHtmlDescription(description),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(color: Color(0xFFE0E0E0), thickness: 1.0),
        ),
      ],
    );
  }

  Widget _buildRatingBreakdown() {
    final Map<int, int> ratingBreakdown = {5: 88, 4: 9, 3: 0, 2: 3, 1: 0};

    return Column(
      children: ratingBreakdown.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Text(
                '${entry.key}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.star,
                size: 16,
                color: Color.fromRGBO(111, 10, 15, 1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: entry.value / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(111, 10, 15, 1),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.value}%',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBadges() {
    final List<Map<String, dynamic>> badges = [
      {'icon': Icons.local_florist, 'label': '100% Pure'},
      {'icon': Icons.lock, 'label': 'Secure Payment'},
      {'icon': Icons.local_dining, 'label': 'Zero Preservatives'},
      {'icon': Icons.energy_savings_leaf, 'label': 'Freshly Made'},
      {'icon': Icons.local_shipping, 'label': 'Fast Shipping'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Choose Us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: badges.map((badge) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 80) / 3,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(111, 10, 15, 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badge['icon'] as IconData,
                        size: 28,
                        color: const Color.fromRGBO(111, 10, 15, 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      badge['label']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    final overallRating = _productDetails?.avgRating ?? 0.0;
    final ratingCount = _productDetails?.totalReviews ?? 0;
    final individualReviews = _productDetails?.reviews ?? [];

    if (individualReviews.isEmpty && ratingCount == 0) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => showReviewDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('No reviews yet. Be the first to review this product!'),
          ],
        ),
      );
    }

    const int reviewsPerPage = 3;

    return StatefulBuilder(
      builder: (context, stateSetter) {
        int totalPages = (individualReviews.length / reviewsPerPage).ceil();
        if (totalPages == 0) totalPages = 1;
        int startIndex = _currentReviewPage * reviewsPerPage;
        int endIndex = (startIndex + reviewsPerPage).clamp(
          0,
          individualReviews.length,
        );
        var currentPageReviews = individualReviews.sublist(
          startIndex,
          endIndex,
        );

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showReviewDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer reviews',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          if (index < overallRating.floor()) {
                            return const Icon(
                              Icons.star,
                              color: Color.fromRGBO(111, 10, 15, 1),
                              size: 24,
                            );
                          } else if (index < overallRating) {
                            return const Icon(
                              Icons.star_half,
                              color: Color.fromRGBO(111, 10, 15, 1),
                              size: 24,
                            );
                          } else {
                            return const Icon(
                              Icons.star_border,
                              color: Color.fromRGBO(111, 10, 15, 1),
                              size: 24,
                            );
                          }
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${overallRating.toStringAsFixed(1)} out of 5',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$ratingCount global ratings',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    _buildRatingBreakdown(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...currentPageReviews.map(
                (review) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          double r = review.rating.toDouble();
                          if (index < r.floor()) {
                            return const Icon(
                              Icons.star,
                              color: Color.fromRGBO(111, 10, 15, 1),
                              size: 16,
                            );
                          } else if (index < r) {
                            return const Icon(
                              Icons.star_half,
                              color: Color.fromRGBO(111, 10, 15, 1),
                              size: 16,
                            );
                          } else {
                            return const Icon(
                              Icons.star_border,
                              color: Color.fromRGBO(111, 10, 15, 1),
                              size: 16,
                            );
                          }
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'By: ${review.customerName}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${review.createdAt.isNotEmpty ? review.createdAt.substring(0, 10) : 'Unknown'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              if (individualReviews.length > reviewsPerPage) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentReviewPage > 0)
                      ElevatedButton.icon(
                        onPressed: () {
                          stateSetter(() {
                            _currentReviewPage--;
                          });
                          setState(() {});
                        },
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Previous'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Text(
                      'Page ${_currentReviewPage + 1} of $totalPages',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_currentReviewPage < totalPages - 1)
                      ElevatedButton.icon(
                        onPressed: () {
                          stateSetter(() {
                            _currentReviewPage++;
                          });
                          setState(() {});
                        },
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Next'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void showReviewDialog(BuildContext context) {
    double rating = 0;
    final reviewController = TextEditingController();
    bool showRatingError = false;
    bool showReviewError = false;
    const maxReviewLength = 200;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Write a Review',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20, color: Colors.grey[600]),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatefulBuilder(
                builder: (context, setter) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => GestureDetector(
                          onTap: () => setter(() {
                            rating = index + 1.0;
                            showRatingError = false;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber[600],
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showRatingError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 8),
                        child: Text(
                          'Please select a rating',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: reviewController,
                maxLines: 4,
                maxLength: maxReviewLength,
                decoration: InputDecoration(
                  hintText: 'Write your review here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(111, 10, 15, 1),
                      width: 2,
                    ),
                  ),
                  errorText: showReviewError ? 'Please write a review' : null,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              foregroundColor: const Color.fromRGBO(111, 10, 15, 1),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              bool hasError = false;
              if (rating == 0) {
                showRatingError = true;
                hasError = true;
              }
              if (reviewController.text.trim().isEmpty) {
                showReviewError = true;
                hasError = true;
              }
              if (hasError) {
                return;
              }
              submitReview(context, rating, reviewController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Submit',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submitReview(
    BuildContext context,
    double rating,
    String description,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id');
      if (customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to submit a review'),
            backgroundColor: Colors.red,
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

      final pId = productId;
      final response = await http
          .post(
            Uri.parse('https://new-test.megascale.co.in/api/p1/addreview'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'customer_id': customerId,
              'product_id': pId,
              'rating': rating.toInt(),
              'description': description,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully'),
            backgroundColor: Color.fromRGBO(111, 10, 15, 1),
          ),
        );
        _loadAllDetails();
      }
    } catch (e) {
      debugPrint('Error submitting review: $e');
    }
  }

  Widget _buildSimilarProducts() {
    if (_similarProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'You Might Also Like',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductListScreen(
                        title: 'All Products',
                        collectionId: '',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color.fromRGBO(111, 10, 15, 1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _similarProducts.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final product = _similarProducts[index];

                double rating = product.avgRating;
                int reviewCount = product.totalReviews;

                String price = product.variants.isNotEmpty
                    ? product.variants[0].price.amount
                    : '0.00';
                String? mrpNullable = product.variants.isNotEmpty
                    ? product.variants[0].compareAtPrice?.amount
                    : null;
                String mrp = mrpNullable ?? price;

                bool hasDiscount =
                    mrpNullable != null &&
                    double.parse(mrp) > double.parse(price);
                final priceValue = double.tryParse(price) ?? 0;
                final mrpValue = double.tryParse(mrp) ?? 0;
                final discountPercent = hasDiscount && mrpValue > 0
                    ? ((mrpValue - priceValue) / mrpValue * 100).round()
                    : 0;

                final displayImgUrl = product.images.isNotEmpty
                    ? product.images[0].url
                    : product.imageUrl;

                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              displayImgUrl.isNotEmpty
                                  ? displayImgUrl
                                  : 'https://via.placeholder.com/150',
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.error,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 12,
                              right: 12,
                              bottom: 12,
                              top: 6,
                            ),
                            //padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // const Spacer(),
                                if (hasDiscount)
                                  Row(
                                    children: [
                                      Text(
                                        '₹$mrp',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E8),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          '$discountPercent% OFF',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₹$price',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color.fromRGBO(111, 10, 15, 1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Flexible(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ...List.generate(5, (i) {
                                            return Icon(
                                              i < rating.floor()
                                                  ? Icons.star
                                                  : i < rating &&
                                                        rating % 1 != 0
                                                  ? Icons.star_half
                                                  : Icons.star_border,
                                              color: const Color.fromRGBO(
                                                111,
                                                10,
                                                15,
                                                1,
                                              ),
                                              size: 14,
                                            );
                                          }),
                                          const SizedBox(width: 4),
                                          Text(
                                            rating > 0
                                                ? '${rating.toStringAsFixed(1)} ($reviewCount)'
                                                : '($reviewCount)',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildBottomBar() {
    if (_productDetails == null) return const SizedBox.shrink();
    final variants = _productDetails!.variants;

    final ProductVariantModel selectedVariant = variants.firstWhere(
      (v) => v.title == _selectedWeight,
      orElse: () => variants.first,
    );
    final bool isOutOfStock = selectedVariant.inventoryQuantity == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isAddingToCart || isOutOfStock
                    ? null
                    : () async {
                        await _addToCart();
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        }
                      },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(
                    color: Color.fromRGBO(111, 10, 15, 1),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Buy Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(111, 10, 15, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isAddingToCart
                    ? null
                    : (isOutOfStock
                          ? () async {
                              try {
                                setState(() {
                                  _isAddingToCart = true;
                                });

                                final String pId = productId;
                                final String productTitle =
                                    _productDetails?.title ?? 'Product';

                                await NotificationServices()
                                    .subscribeToBackInStock(
                                      productId: pId,
                                      productTitle: productTitle,
                                    );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'You will be notified when this is back in stock',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll(
                                          'Exception: ',
                                          '',
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isAddingToCart = false;
                                  });
                                }
                              }
                            }
                          : _addToCart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOutOfStock
                      ? Colors.orange
                      : const Color.fromRGBO(111, 10, 15, 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        isOutOfStock ? 'Notify me' : 'Add to Cart',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    try {
      setState(() {
        _isAddingToCart = true;
      });

      if (_productDetails == null || _productDetails!.variants.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No variants available for this product.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final variants = _productDetails!.variants;
      final ProductVariantModel selectedVariant = variants.firstWhere(
        (v) => v.title == _selectedWeight,
        orElse: () => variants.first,
      );
      final selectedVariantId = selectedVariant.id.toString();

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.addToCart(
        CartItem(
          productId: _productDetails!.id,
          variantId: selectedVariantId,
          price: double.tryParse(_selectedPrice ?? '0.0') ?? 0.0,
          compareAtPrice:
              double.tryParse(_productDetails!.compareAtPrice ?? '0.0') ?? 0.0,
          quantity: 1,
          sku: selectedVariant.sku ?? 'SKU-${_productDetails!.id}',
          title: _productDetails!.title,
          imageUrl: _productDetails!.imageUrl,
          weight: _selectedWeight ?? '',
        ),
      );

      final success = await cartProvider.proceedToCheckout();
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SizedBox(
              height: 60,
              child: Row(
                children: [
                  if (_productDetails!.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _productDetails!.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Added to Cart',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _productDetails!.title,
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              cartProvider.errorMessage ?? 'Failed to update backend session',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }

      await _loadCartCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Widget _buildFAQSection() {
    int selectedLanguage = 0;
    int expandedIndex = -1;

    final List<Map<String, Map<String, String>>> faqs = [
      {
        'en': {
          'question':
              'Why Is COD (Cash On Delivery) Not Available At Shree Nilkanth Store?',
          'answer':
              'To ensure smooth order processing and avoid returns of fragile pooja items like kalash, murtis, and copper products, we currently accept only prepaid orders.',
        },
        'hi': {
          'question':
              'श्री नीलकंठ स्टोर पर COD (कैश ऑन डिलीवरी) क्यों उपलब्ध नहीं है?',
          'answer':
              'ऑर्डर की प्रक्रिया को सुचारु रखने और कलश, मूर्तियों एवं तांबे के उत्पादों जैसी नाजुक पूजा वस्तुओं की वापसी से बचने के लिए, हम वर्तमान में केवल प्रीपेड ऑर्डर स्वीकार करते हैं।',
        },
        'gu': {
          'question':
              'શ્રી નીલકંઠ સ્ટોર પર COD (કેશ ઓન ડિલિવરી) કેમ ઉપલબ્ધ નથી?',
          'answer':
              'ઓર્ડરની પ્રક્રિયા સરળતાથી થાય અને કલશ, મૂર્તિઓ તથા તાંબાના ઉત્પાદનો જેવી નાજુક પૂજા સામગ્રી પરત ન આવે તે માટે, અમે હાલમાં માત્ર પ્રીપેડ ઓર્ડર સ્વીકારીએ છીએ.',
        },
      },
      {
        'en': {
          'question': 'What Is Shree Nilkanth Store?',
          'answer':
              'Shree Nilkanth Store is an online spiritual and pooja essentials shop offering Pital & Copper items, Pooja Samagri, Attar & Aroma products, Agarbatti–Dhoop, Aushadhi, Cosmetics, and devotional gift items.',
        },
        'hi': {
          'question': 'श्री नीलकंठ स्टोर क्या है?',
          'answer':
              'श्री नीलकंठ स्टोर एक ऑनलाइन आध्यात्मिक और पूजा आवश्यकताओं की दुकान है, जहाँ पीतल एवं तांबे की वस्तुएँ, पूजा सामग्री, इत्र एवं अरोमा उत्पाद, अगरबत्ती–धूप, औषधि, कॉस्मेटिक्स और भक्तिमय उपहार सामग्री उपलब्ध हैं।',
        },
        'gu': {
          'question': 'શ્રી નીલકંઠ સ્ટોર શું છે?',
          'answer':
              'શ્રી નીલકંઠ સ્ટોર એક ઓનલાઈન આધ્યાત્મિક અને પૂજા સામગ્રીની દુકાન છે, જ્યાં પિત્તળ અને તાંબાની વસ્તુઓ, પૂજા સામગ્રી, અત્તર અને અરોમા પ્રોડક્ટ્સ, અગરબત્તી–ધૂપ, ઔષધિ, કોસ્મેટિક્સ અને ભક્તિમય ગિફ્ટ વસ્તુઓ ઉપલબ્ધ છે.',
        },
      },
      {
        'en': {
          'question':
              'How Are Shree Nilkanth Store Products Different From Others?',
          'answer':
              'At Shree Nilkanth Store, many of our pooja items are first offered to the divine before they reach you. This makes every product not just a purchase, but a blessed offering filled with spiritual value and purity.',
        },
        'hi': {
          'question': 'श्री नीलकंठ स्टोर के उत्पाद दूसरों से अलग कैसे हैं?',
          'answer':
              'श्री नीलकंठ स्टोर में हमारी कई पूजा वस्तुएँ आप तक पहुँचने से पहले भगवान को अर्पित की जाती हैं। इससे प्रत्येक उत्पाद केवल एक खरीदारी नहीं, बल्कि आध्यात्मिक मूल्य और पवित्रता से युक्त एक आशीर्वादित भेंट बन जाता है।',
        },
        'gu': {
          'question':
              'શ્રી નીલકંઠ સ્ટોરના ઉત્પાદનો અન્ય ઉત્પાદનો કરતાં અલગ કેવી રીતે છે?',
          'answer':
              'શ્રી નીલકંઠ સ્ટોરમાં અમારી ઘણી પૂજા સામગ્રી તમારા સુધી પહોંચે તે પહેલાં ભગવાનને અર્પણ કરવામાં આવે છે. તેથી દરેક ઉત્પાદન માત્ર ખરીદી નથી, પરંતુ આધ્યાત્મિક મૂલ્ય અને પવિત્રતાથી ભરપૂર આશીર્વાદિત અર્પણ બની જાય છે.',
        },
      },
      {
        'en': {
          'question':
              'Are Shree Nilkanth Store Products Completely Suitable For Pooja?',
          'answer':
              'Yes. All items—from Kalash and Lota to Chandan Powder, Agarbatti, Kanthi Mala, and Murti—are pooja-friendly and prepared according to spiritual standards.',
        },
        'hi': {
          'question':
              'क्या श्री नीलकंठ स्टोर के उत्पाद पूजा के लिए पूरी तरह उपयुक्त हैं?',
          'answer':
              'हाँ। कलश और लोटा से लेकर चंदन पाउडर, अगरबत्ती, कंठी माला और मूर्ति तक सभी वस्तुएँ पूजा के लिए उपयुक्त हैं और आध्यात्मिक मानकों के अनुसार तैयार की जाती हैं।',
        },
        'gu': {
          'question':
              'શું શ્રી નીલકંઠ સ્ટોરના ઉત્પાદનો પૂજા માટે સંપૂર્ણપણે યોગ્ય છે?',
          'answer':
              'હા. કલશ અને લોટાથી લઈને ચંદન પાવડર, અગરબત્તી, કંઠી માળા અને મૂર્તિ સુધીની તમામ વસ્તુઓ પૂજા માટે યોગ્ય છે અને આધ્યાત્મિક ધોરણો અનુસાર તૈયાર કરવામાં આવે છે.',
        },
      },
      {
        'en': {
          'question': 'Is Shree Nilkanth Store Only For Religious Purposes?',
          'answer':
              'While most products are pooja-related, we also offer everyday-use items such as attars, perfumes, herbal cosmetics, and decorative gift items suitable for home and personal use.',
        },
        'hi': {
          'question':
              'क्या श्री नीलकंठ स्टोर केवल धार्मिक उद्देश्यों के लिए है?',
          'answer':
              'हालाँकि हमारे अधिकांश उत्पाद पूजा से संबंधित हैं, हम रोज़मर्रा के उपयोग की वस्तुएँ जैसे इत्र, परफ्यूम, हर्बल कॉस्मेटिक्स और सजावटी उपहार सामग्री भी उपलब्ध कराते हैं, जो घर और व्यक्तिगत उपयोग के लिए उपयुक्त हैं।',
        },
        'gu': {
          'question': 'શું શ્રી નીલકંઠ સ્ટોર માત્ર ધાર્મિક હેતુઓ માટે છે?',
          'answer':
              'અમારા મોટાભાગના ઉત્પાદનો પૂજા સંબંધિત છે, પરંતુ અમે રોજિંદા ઉપયોગ માટેની વસ્તુઓ જેમ કે અત્તર, પરફ્યુમ, હર્બલ કોસ્મેટિક્સ અને ઘર તથા વ્યક્તિગત ઉપયોગ માટે યોગ્ય સુશોભન ગિફ્ટ વસ્તુઓ પણ ઉપલબ્ધ કરાવીએ છીએ.',
        },
      },
      {
        'en': {
          'question': 'What Varieties Of Pooja Items Do You Offer?',
          'answer':
              'We offer Pital & Copper items, Murti, Kanthi Mala, Chandan Powder, Toran, Agarbatti–Dhoop, Attar, Perfumes, Air Fresheners, Aushadhi, Face & Hair products, and many spiritual accessories.',
        },
        'hi': {
          'question': 'आप किस प्रकार की पूजा सामग्री उपलब्ध कराते हैं?',
          'answer':
              'हम पीतल एवं तांबे की वस्तुएँ, मूर्तियाँ, कंठी माला, चंदन पाउडर, तोरण, अगरबत्ती–धूप, इत्र, परफ्यूम, एयर फ्रेशनर, औषधि, फेस एवं हेयर उत्पाद और कई आध्यात्मिक उपयोग की वस्तुएँ उपलब्ध कराते हैं।',
        },
        'gu': {
          'question': 'તમે કયા પ્રકારની પૂજા સામગ્રી ઉપલબ્ધ કરાવો છો?',
          'answer':
              'અમે પિત્તળ અને તાંબાની વસ્તુઓ, મૂર્તિઓ, કંઠી માળા, ચંદન પાવડર, તોરણ, અગરબત્તી–ધૂપ, અત્તર, પરફ્યુમ, એર ફ્રેશનર, ઔષધિ, ફેસ અને હેર પ્રોડક્ટ્સ તેમજ ઘણી આધ્યાત્મિક ઉપયોગની વસ્તુઓ ઉપલબ્ધ કરાવીએ છીએ.',
        },
      },
      {
        'en': {
          'question': 'How Do You Ensure Quality And Purity?',
          'answer':
              'Every item is checked for authenticity—metal products for material purity, pooja samagri for freshness, and aushadhi–cosmetic items for herbal safety and quality.',
        },
        'hi': {
          'question': 'आप गुणवत्ता और शुद्धता कैसे सुनिश्चित करते हैं?',
          'answer':
              'प्रत्येक वस्तु की प्रामाणिकता की जाँच की जाती है—धातु उत्पादों में सामग्री की शुद्धता, पूजा सामग्री में ताज़गी और औषधि–कॉस्मेटिक उत्पादों में हर्बल सुरक्षा एवं गुणवत्ता की जाँच की जाती है।',
        },
        'gu': {
          'question': 'તમે ગુણવત્તા અને શુદ્ધતા કેવી રીતે સુનિશ્ચિત કરો છો?',
          'answer':
              'દરેક વસ્તુની પ્રમાણિકતા ચકાસવામાં આવે છે—ધાતુના ઉત્પાદનોમાં સામગ્રીની શુદ્ધતા, પૂજા સામગ્રીમાં તાજગી અને ઔષધિ–કોસ્મેટિક ઉત્પાદનોમાં હર્બલ સુરક્ષા તથા ગુણવત્તાની ચકાસણી કરવામાં આવે છે.',
        },
      },
      {
        'en': {
          'question': 'Can Shree Nilkanth Store Products Be Given As A Gift?',
          'answer':
              'Yes. Items like murtis, car stands, toran, attars, and decorative pooja products make beautiful and meaningful spiritual gifts for any occasion.',
        },
        'hi': {
          'question':
              'क्या श्री नीलकंठ स्टोर के उत्पाद उपहार के रूप में दिए जा सकते हैं?',
          'answer':
              'हाँ। मूर्तियाँ, कार स्टैंड, तोरण, इत्र और सजावटी पूजा उत्पाद जैसे सामान किसी भी अवसर पर सुंदर और अर्थपूर्ण आध्यात्मिक उपहार के लिए उपयुक्त हैं।',
        },
        'gu': {
          'question': 'શું શ્રી નીલકંઠ સ્ટોરના ઉત્પાદનો ભેટ તરીકે આપી શકાય છે?',
          'answer':
              'હા. મૂર્તિઓ, કાર સ્ટેન્ડ, તોરણ, અત્તર અને સુશોભન પૂજા ઉત્પાદનો જેવી વસ્તુઓ કોઈપણ પ્રસંગે સુંદર અને અર્થપૂર્ણ આધ્યાત્મિક ભેટ બની શકે છે.',
        },
      },
    ];

    String getLangKey() {
      switch (selectedLanguage) {
        case 1:
          return 'hi';
        case 2:
          return 'gu';
        default:
          return 'en';
      }
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: const Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Color.fromRGBO(111, 10, 15, 1),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
        children: [
          StatefulBuilder(
            builder: (context, stateSetter) {
              final langKey = getLangKey();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ToggleButtons(
                        borderRadius: BorderRadius.circular(30),
                        selectedColor: Colors.white,
                        fillColor: const Color.fromRGBO(111, 10, 15, 1),
                        color: Colors.grey[700],
                        constraints: const BoxConstraints(
                          minHeight: 32,
                          minWidth: 56,
                        ),
                        isSelected: [
                          selectedLanguage == 0,
                          selectedLanguage == 1,
                          selectedLanguage == 2,
                        ],
                        onPressed: (int index) {
                          stateSetter(() {
                            selectedLanguage = index;
                            expandedIndex = -1;
                          });
                        },
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'EN',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'हिंदी',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'ગુજરાતી',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: faqs.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final faq = entry.value[langKey]!;

                        final item = Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: const EdgeInsets.fromLTRB(
                              0,
                              0,
                              0,
                              8,
                            ),
                            trailing: Icon(
                              expandedIndex == idx
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            onExpansionChanged: (expanded) {
                              stateSetter(() {
                                expandedIndex = expanded ? idx : -1;
                              });
                            },
                            title: Text(
                              faq['question']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            children: [
                              Text(
                                faq['answer']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );

                        if (idx < faqs.length - 1) {
                          return Column(
                            children: [
                              item,
                              Divider(
                                color: Colors.grey[300],
                                height: 1,
                                thickness: 1,
                              ),
                            ],
                          );
                        }
                        return item;
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 350,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 24,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 20,
                              width: 20,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
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
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _buildAppBar(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _productDetails?.title ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹$_selectedPrice',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(111, 10, 15, 1),
                        ),
                      ),
                      if (_selectedMRP != null &&
                          _selectedMRP != _selectedPrice &&
                          (double.tryParse(_selectedMRP!) ?? 0) >
                              (double.tryParse(_selectedPrice!) ?? 0)) ...[
                        const SizedBox(width: 8),
                        Text(
                          '₹$_selectedMRP',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${(((double.parse(_selectedMRP!) - double.parse(_selectedPrice!)) / double.parse(_selectedMRP!)) * 100).toStringAsFixed(0)}% OFF',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        double rating = _productDetails?.avgRating ?? 0.0;
                        if (index < rating.floor()) {
                          return const Icon(
                            Icons.star,
                            color: Color.fromRGBO(111, 10, 15, 1),
                            size: 24,
                          );
                        } else if (index < rating) {
                          return const Icon(
                            Icons.star_half,
                            color: Color.fromRGBO(111, 10, 15, 1),
                            size: 24,
                          );
                        } else {
                          return const Icon(
                            Icons.star_border,
                            color: Color.fromRGBO(111, 10, 15, 1),
                            size: 24,
                          );
                        }
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '${(_productDetails?.avgRating ?? 0.0).toStringAsFixed(1)} ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        (_productDetails?.totalReviews ?? 0) > 0
                            ? '(${_productDetails!.totalReviews})'
                            : 'No ratings yet',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('👀', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              '${_generateRandomViewingCount()} customers are viewing this product',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              '${_generateRandomSalesCount()} sold in last ${_generateRandomTimePeriod()}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: _buildQuantitySelector(),
            ),
            const SizedBox(height: 12),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [_buildDescription(), _buildFAQSection()],
              ),
            ),
            const SizedBox(height: 16),
            _buildBadges(),
            _buildReviews(),
            _buildSimilarProducts(),
            const SizedBox(height: 30),
            RecentPurchaseNotification(
              currentProductTitle: _productDetails?.title ?? 'this product',
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  @override
  void dispose() {
    _imagePageController?.dispose();
    super.dispose();
  }
}
