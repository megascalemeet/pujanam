import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pujanam/pages/products/product_detail_screen.dart';
import 'package:pujanam/theme/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/category/category_product_response_model.dart';
import '../../models/search/search_response_model.dart';
import '../../providers/category/category_provider.dart';
import '../../services/smart_search_service.dart';
import '../../widgets/advanced_filter_widget.dart';
import '../auth/login.dart';
import '../cart/cart_screen.dart';

class CategoryProductListScreen extends StatefulWidget {
  final String title;
  final String handle;

  const CategoryProductListScreen({
    super.key,
    required this.title,
    required this.handle,
  });

  @override
  _CategoryProductListScreenState createState() =>
      _CategoryProductListScreenState();
}

class _CategoryProductListScreenState extends State<CategoryProductListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Map<String, bool> _wishlistStatus = {};
  Map<String, bool> _isAddingToWishlist = {};
  int _cartCount = 0; // Placeholder
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  SortOption _sortOption = SortOption.none;
  FilterCriteria _filterCriteria = FilterCriteria();

  // Search API State
  final SmartSearchService _smartSearchService = SmartSearchService();
  List<dynamic> _apiSearchProducts = [];
  bool _isApiSearchActive = false;
  bool _isApiSearchLoading = false;
  Timer? _searchApiDebounce;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    _searchController.addListener(_onSearchChangedApi);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchProducts(widget.handle);
    });
  }

  void _onSearchChangedApi() {
    _searchApiDebounce?.cancel();
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _apiSearchProducts = [];
        _isApiSearchActive = false;
        _isApiSearchLoading = false;
      });
      return;
    }

    setState(() => _isApiSearchLoading = true);

    _searchApiDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _smartSearchService.searchProducts(query);
        if (mounted) {
          setState(() {
            _apiSearchProducts = results['products'] ?? [];
            _isApiSearchActive = true;
            _isApiSearchLoading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isApiSearchLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChangedApi);
    _searchApiDebounce?.cancel();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getProductId(String id) {
    return id.split('/').last;
  }

  Future<void> _toggleWishlist(BuildContext context, String productId) async {
    if (_isAddingToWishlist[productId] ?? false) return;
    final normalizedId = _getProductId(productId);

    setState(() {
      _wishlistStatus[productId] = !(_wishlistStatus[productId] ?? false);
      _isAddingToWishlist[productId] = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id');
      if (customerId == null) {
        setState(() {
          _wishlistStatus[productId] = false;
          _isAddingToWishlist[productId] = false;
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
      if (_wishlistStatus[productId] ?? false) {
        response = await http
            .post(
              Uri.parse(
                'https://new-test.megascale.co.in/api/p1/addtowishlist',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Connection': 'Keep-Alive',
              },
              body: json.encode({
                'customer_id': customerId,
                'product_id': normalizedId,
              }),
            )
            .timeout(const Duration(seconds: 30));
      } else {
        response = await http
            .delete(
              Uri.parse(
                'https://new-test.megascale.co.in/api/p1/removewishlist',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Connection': 'Keep-Alive',
              },
              body: json.encode({
                'customer_id': customerId,
                'product_id': normalizedId,
              }),
            )
            .timeout(const Duration(seconds: 30));
      }

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _wishlistStatus[productId]!
                  ? 'Added to wishlist'
                  : 'Removed from wishlist',
            ),
            backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        setState(
          () => _wishlistStatus[productId] = !(_wishlistStatus[productId]!),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update wishlist'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(
        () => _wishlistStatus[productId] = !(_wishlistStatus[productId]!),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating wishlist'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    } finally {
      setState(() => _isAddingToWishlist[productId] = false);
    }
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: AdvancedFilterWidget(
          currentFilters: _filterCriteria,
          currentSort: _sortOption,
          minPrice: 0,
          maxPrice: 10000,
          availableBrands: const ["Nilkanth", "Divine", "Traditional"],
          availableSizes: const ["100g", "250g", "500g"],
          availableColors: const [],
          availableCategories: const [],
          onFiltersChanged: (filters) =>
              setState(() => _filterCriteria = filters),
          onSortChanged: (sort) => setState(() => _sortOption = sort),
          onFiltersCleared: () => setState(() {
            _filterCriteria.clearAll();
            _sortOption = SortOption.none;
          }),
        ),
      ),
    );
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
    const brandColor = Color.fromRGBO(111, 10, 15, 1);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: brandColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                if (_cartCount > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _cartCount.toString(),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async => provider.fetchProducts(widget.handle),
            color: brandColor,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(Icons.search, color: brandColor),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _apiSearchProducts = [];
                                    _isApiSearchActive = false;
                                    _isApiSearchLoading = false;
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),

                  _buildSortFilterBar(brandColor),

                  if (_isApiSearchActive || _isApiSearchLoading)
                    _buildApiSearchResultGrid(brandColor)
                  else if (provider.isProductsLoading)
                    _buildShimmerProducts()
                  else if (provider.productsError != null)
                    _buildErrorState(
                      provider.productsError!,
                      () => provider.fetchProducts(widget.handle),
                    )
                  else if (provider.products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'No products found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    )
                  else
                    _buildProductGrid(provider.products, brandColor),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortFilterBar(Color brandColor) {
    bool hasActive =
        _filterCriteria.hasActiveFilters || _sortOption != SortOption.none;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showAdvancedFilters,
              icon: const Icon(Icons.filter_list, size: 18),
              label: Text(
                _sortOption == SortOption.none
                    ? 'Sort & Filter'
                    : _sortOption.displayName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasActive ? brandColor : Colors.white,
                foregroundColor: hasActive ? Colors.white : brandColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: hasActive ? Colors.transparent : Colors.grey[300]!,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (hasActive) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() {
                _filterCriteria.clearAll();
                _sortOption = SortOption.none;
              }),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.red[700],
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCardItem({
    required dynamic originalProduct, // for navigation and wishlist
    required String id,
    required String? imageUrl,
    required String title,
    required double price,
    required double compareAtPrice,
    required double avgRating,
    required int totalReviews,
    required Color brandColor,
  }) {
    final double fontSize = MediaQuery.of(context).size.width * 0.035;
    final bool hasDiscount = compareAtPrice > price;
    final String? discountPercent = hasDiscount
        ? ((compareAtPrice - price) / compareAtPrice * 100).toStringAsFixed(0)
        : null;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: originalProduct),
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
                    tag: 'product-${_getProductId(id)}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: Image.network(
                        imageUrl ?? 'https://via.placeholder.com/150',
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
                        title,
                        style: TextStyle(
                          fontSize: fontSize - 2,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
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
                              color: brandColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 4),
                            Text(
                              '₹${compareAtPrice.toInt()}',
                              style: TextStyle(
                                fontSize: fontSize - 4,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                                fontFamily: 'Poppins',
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
                                '$discountPercent% OFF',
                                style: TextStyle(
                                  fontSize: fontSize - 4,
                                  color: const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStarRating(avgRating, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '($totalReviews)',
                            style: TextStyle(
                              fontSize: fontSize - 4,
                              color: Colors.grey[600],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasDiscount)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$discountPercent% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _toggleWishlist(context, id),
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
                  child: _isAddingToWishlist[id] == true
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              brandColor,
                            ),
                          ),
                        )
                      : Icon(
                          _wishlistStatus[id] == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _wishlistStatus[id] == true
                              ? brandColor
                              : Colors.grey[600],
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

  Widget _buildApiSearchResultGrid(Color brandColor) {
    if (_isApiSearchLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(brandColor),
          ),
        ),
      );
    }

    if (_apiSearchProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'No results for "${_searchController.text.trim()}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _apiSearchProducts.length,
      itemBuilder: (context, index) {
        final raw = _apiSearchProducts[index];
        final searchProduct = SearchProduct.fromJson(
          Map<String, dynamic>.from(raw as Map),
        );
        final cardMap = searchProduct.toProductCardMap();

        return _buildProductCardItem(
          originalProduct: cardMap,
          id: searchProduct.id,
          imageUrl: searchProduct.imageUrl,
          title: searchProduct.title,
          price: searchProduct.price,
          compareAtPrice: searchProduct.compareAtPrice ?? searchProduct.price,
          avgRating: searchProduct.rating,
          totalReviews: searchProduct.reviewCount,
          brandColor: brandColor,
        );
      },
    );
  }

  Widget _buildProductGrid(
    List<CategoryProductModel> products,
    Color brandColor,
  ) {
    final query = _searchController.text.toLowerCase();

    List<CategoryProductModel> filtered = products
        .where((p) => p.title.toLowerCase().contains(query))
        .toList();

    if (_filterCriteria.priceRange != null) {
      filtered = filtered
          .where(
            (p) =>
                p.price >= _filterCriteria.priceRange!.start &&
                p.price <= _filterCriteria.priceRange!.end,
          )
          .toList();
    }

    if (_sortOption == SortOption.priceLowToHigh) {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == SortOption.priceHighToLow) {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];

        return _buildProductCardItem(
          originalProduct: product,
          id: product.id,
          imageUrl: product.imageUrl,
          title: product.title,
          price: product.price,
          compareAtPrice: product.compareAtPrice,
          avgRating: product.avgRating,
          totalReviews: product.totalReviews,
          brandColor: brandColor,
        );
      },
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildShimmerProducts() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
