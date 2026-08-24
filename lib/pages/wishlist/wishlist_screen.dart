import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/wishlist/wishlist_provider.dart';
import '../../services/product/product_api_service.dart';
import '../products/product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final Map<String, Map<String, dynamic>> _reviewsCache = {};
  bool _fetchingReviews = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().fetchWishlist().then((_) {
        _fetchReviewsForWishlistItems();
      });
    });
  }

  Future<void> _fetchReviewsForWishlistItems() async {
    if (_fetchingReviews) return;
    _fetchingReviews = true;

    final provider = context.read<WishlistProvider>();
    final items = provider.items;
    final productApiService = ProductApiService();

    for (var item in items) {
      final productData = item['product'] ?? item;
      String productId = productData['id']?.toString().replaceAll('gid://shopify/Product/', '').trim() ??
          productData['product_id']?.toString() ??
          '';

      if (productId.isEmpty || _reviewsCache.containsKey(productId)) continue;

      try {
        final summary = await productApiService.fetchProductReviewSummary(productId);
        if (summary.isNotEmpty) {
           final rating = double.tryParse(summary['avg_rating']?.toString() ?? '0') ?? 0.0;
           final count = int.tryParse(summary['total_reviews']?.toString() ?? '0') ?? 0;
           if (mounted) {
             setState(() {
               _reviewsCache[productId] = {
                 'rating': rating,
                 'count': count,
               };
             });
           }
        }
      } catch (e) {
        debugPrint('Error fetching reviews for $productId: $e');
      }
    }
    if (mounted) {
      setState(() {
        _fetchingReviews = false;
      });
    } else {
      _fetchingReviews = false;
    }
  }

  Widget _buildShimmerLoading() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    int crossAxisCount = 2;
    if (screenSize.width > 900) {
      crossAxisCount = 4;
    } else if (screenSize.width > 600) {
      crossAxisCount = 3;
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.75,
          crossAxisSpacing: isSmallScreen ? 8 : 16,
          mainAxisSpacing: isSmallScreen ? 8 : 16,
        ),
        itemCount: crossAxisCount * 2,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: screenSize.width / (crossAxisCount * 1.5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: isSmallScreen ? 10 : 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: isSmallScreen ? 80 : 100,
                        height: isSmallScreen ? 10 : 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: isSmallScreen ? 50 : 60,
                        height: isSmallScreen ? 14 : 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyWishlist() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        final iconSize = maxWidth < 300 ? 50.0 : (isSmallScreen ? 64.0 : 80.0);
        final titleFontSize = maxWidth < 300 ? 16.0 : (isSmallScreen ? 18.0 : 20.0);
        final messageFontSize = maxWidth < 300 ? 12.0 : (isSmallScreen ? 14.0 : 16.0);

        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: iconSize,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: maxHeight * 0.03),
                  Text(
                    'Your wishlist is empty',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: maxHeight * 0.015),
                  SizedBox(
                    width: maxWidth * 0.8,
                    child: Text(
                      'Add items that you like to your wishlist',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: messageFontSize,
                        color: Colors.grey[600],
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
  }

  Widget _buildStarRating(double rating, {double size = 16}) {
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

    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width < 600;

    int crossAxisCount = 2;
    if (screenSize.width > 900) {
      crossAxisCount = 4;
    } else if (screenSize.width > 600) {
      crossAxisCount = 3;
    }

    double childAspectRatio = 0.7;
    double fontSize = MediaQuery.of(context).size.width * 0.035;

    return Consumer<WishlistProvider>(
      builder: (context, provider, child) {
        final wishlistItems = provider.items;
        final isLoading = provider.isLoading;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'My Wishlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 18 : (isMediumScreen ? 20 : 22),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoading ? '0 items' : '${wishlistItems.length} items',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 12 : (isMediumScreen ? 14 : 16),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(isSmallScreen ? 20 : 30),
              ),
            ),
            elevation: 0,
          ),
          body: isLoading
              ? _buildShimmerLoading()
              : wishlistItems.isEmpty
                  ? _buildEmptyWishlist()
                  : RefreshIndicator(
                      onRefresh: () => provider.fetchWishlist().then((_) => _fetchReviewsForWishlistItems()),
                      color: const Color.fromRGBO(111, 10, 15, 1),
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : (isMediumScreen ? 16 : 24),
                          vertical: isSmallScreen ? 10 : (isMediumScreen ? 16 : 24),
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: isSmallScreen ? 8 : (isMediumScreen ? 16 : 24),
                          mainAxisSpacing: isSmallScreen ? 8 : (isMediumScreen ? 16 : 24),
                        ),
                        itemCount: wishlistItems.length,
                        itemBuilder: (context, index) {
                          final item = wishlistItems[index];
                          final productData = item['product'] ?? item;

                          // Image extraction with fallback
                          String imageUrl = '';
                          try {
                            if (productData['image'] != null && productData['image'].toString().isNotEmpty) {
                              imageUrl = productData['image'].toString();
                            } else if (productData['image_url'] != null && productData['image_url'].toString().isNotEmpty) {
                              imageUrl = productData['image_url'].toString();
                            } else if (productData['images'] != null &&
                                productData['images'] is List &&
                                productData['images'].isNotEmpty) {
                              var firstImage = productData['images'][0];
                              if (firstImage is Map) {
                                imageUrl = (firstImage['url'] ?? firstImage['src'] ?? '').toString();
                              }
                            }
                          } catch (e) {
                            debugPrint("Error extracting image for ${productData['product_title'] ?? productData['title']}: $e");
                          }

                          // Price extraction with fallback
                          String price = '0.00';
                          String compareAtPrice = '';
                          try {
                            if (productData['price'] != null && productData['price'].toString().isNotEmpty) {
                              price = productData['price'].toString();
                            }
                            if (productData['compare_at_price'] != null && productData['compare_at_price'].toString().isNotEmpty) {
                              compareAtPrice = productData['compare_at_price'].toString();
                            } else if (productData['compareAtPrice'] != null && productData['compareAtPrice'].toString().isNotEmpty) {
                              compareAtPrice = productData['compareAtPrice'].toString();
                            }

                            if (productData['variants'] != null &&
                                productData['variants'] is List &&
                                productData['variants'].isNotEmpty) {
                              var firstVariant = productData['variants'][0];
                              if (firstVariant is Map) {
                                if (price == '0.00' && firstVariant.containsKey('price')) {
                                  price = firstVariant['price'].toString();
                                }
                                if (compareAtPrice.isEmpty && firstVariant.containsKey('compareAtPrice') && firstVariant['compareAtPrice'] != null) {
                                  compareAtPrice = firstVariant['compareAtPrice'].toString();
                                }
                              }
                            }
                          } catch (e) {
                            debugPrint("Error extracting price for ${productData['product_title'] ?? productData['title']}: $e");
                          }

                          // Rating and review count extraction with cache check
                          String productId = productData['id']?.toString().replaceAll('gid://shopify/Product/', '').trim() ??
                              productData['product_id']?.toString() ??
                              '';
                          double rating = 0.0;
                          int reviewCount = 0;

                          if (_reviewsCache.containsKey(productId)) {
                            rating = _reviewsCache[productId]?['rating'] ?? 0.0;
                            reviewCount = _reviewsCache[productId]?['count'] ?? 0;
                          }

                          final displayTitle = productData['product_title'] ?? productData['title'] ?? 'No Title';

                          return GestureDetector(
                            onTap: () {
                              final detailProduct = Map<String, dynamic>.from(productData);
                              if (detailProduct['handle'] == null && detailProduct['product_handle'] != null) {
                                detailProduct['handle'] = detailProduct['product_handle'];
                              }
                              if (detailProduct['id'] == null && detailProduct['product_id'] != null) {
                                detailProduct['id'] = detailProduct['product_id'];
                              }
                              if (detailProduct['title'] == null && detailProduct['product_title'] != null) {
                                detailProduct['title'] = detailProduct['product_title'];
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    product: detailProduct,
                                  ),
                                ),
                              ).then((_) => provider.fetchWishlist().then((_) => _fetchReviewsForWishlistItems()));
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
                                          tag: 'product-${productData['id'] ?? productData['product_id'] ?? 'unknown'}',
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                            child: Image.network(
                                              imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/150',
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
                                              displayTitle,
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
                                                  price.isNotEmpty ? '₹${double.tryParse(price)?.toInt() ?? price}' : 'Price-',
                                                  style: TextStyle(
                                                    fontSize: fontSize,
                                                    color: const Color.fromRGBO(111, 10, 15, 1),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (compareAtPrice.isNotEmpty &&
                                                    double.tryParse(compareAtPrice) != null &&
                                                    double.tryParse(price) != null &&
                                                    double.parse(compareAtPrice) > double.parse(price)) ...[
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '₹${double.tryParse(compareAtPrice)?.toInt() ?? compareAtPrice}',
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
                                                      '${((double.parse(compareAtPrice) - double.parse(price)) / double.parse(compareAtPrice) * 100).toStringAsFixed(0)}% OFF',
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
                                                _buildStarRating(rating, size: 12),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '($reviewCount)',
                                                  style: TextStyle(
                                                    fontSize: fontSize - 4,
                                                    color: Colors.grey[600],
                                                  ),
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
                                      onTap: () => provider.removeFromWishlist(productId),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Color.fromRGBO(111, 10, 15, 1),
                                          size: 16,
                                        ),
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
        );
      },
    );
  }
}
