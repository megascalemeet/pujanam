import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/product/product_response_model.dart';
import '../../models/search/search_response_model.dart';
import '../../providers/product/product_provider.dart';
import '../../services/smart_search_service.dart';
import '../../widgets/advanced_filter_widget.dart';
import '../../widgets/product/pagination_loader.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/product/product_shimmer.dart';
import '../cart/cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String title;
  final String collectionId;

  const ProductListScreen({
    Key? key,
    required this.title,
    required this.collectionId,
  }) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int cartItemCount = 0;
  String? customerId;
  SortOption _sortOption = SortOption.none;
  FilterCriteria _filterCriteria = FilterCriteria();

  // Available filter options (populated from products)
  List<String> _availableBrands = [];
  List<String> _availableSizes = [];
  List<String> _availableColors = [];
  List<String> _availableCategories = [];
  double _minPrice = 0;
  double _maxPrice = 10000;

  // API search state
  final SmartSearchService _smartSearchService = SmartSearchService();
  List<dynamic> _apiSearchProducts = [];
  bool _isApiSearchActive = false;
  bool _isApiSearchLoading = false;
  Timer? _searchApiDebounce;

  @override
  void initState() {
    super.initState();
    _loadCustomerIdAndCartCount();
    searchController.text = '';

    // Load initial products from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadInitialProducts();
    });

    searchController.addListener(_onSearchChangedApi);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<ProductProvider>().loadMoreProducts();
    }
  }

  void _updateFilterOptionFields(List<ProductModel> products) {
    final brands = <String>{};
    final sizes = <String>{};
    final colors = <String>{};
    final categories = <String>{};
    double minPrice = double.infinity;
    double maxPrice = 0;

    for (final product in products) {
      for (final tag in product.tags) {
        if (tag.toLowerCase().contains('brand') || tag.length > 3) {
          brands.add(tag);
        }
      }

      for (final variant in product.variants) {
        final title = variant.title;
        if (title.isNotEmpty && title != 'Default Title') {
          sizes.add(title);
        }
      }

      // Read categories
      for (final option in product.options) {
        if (option.name.toLowerCase() == 'category') {
          categories.addAll(option.values);
        }
      }

      for (final variant in product.variants) {
        final price = double.tryParse(variant.price.amount) ?? 0.0;
        if (price > 0) {
          minPrice = minPrice < price ? minPrice : price;
          maxPrice = maxPrice > price ? maxPrice : price;
        }
      }
    }

    _availableBrands = brands.toList()..sort();
    _availableSizes = sizes.toList()..sort();
    _availableColors = colors.toList()..sort();
    _availableCategories = categories.toList()..sort();
    _minPrice = minPrice == double.infinity ? 0 : minPrice;
    _maxPrice = maxPrice == 0 ? 10000 : maxPrice;
  }

  List<ProductModel> _buildFilteredList(List<ProductModel> allProducts) {
    final query = searchController.text.toLowerCase().trim();

    final result = allProducts.where((product) {
      // Text search filter
      if (query.isNotEmpty) {
        final title = product.title.toLowerCase();
        final description = product.description.toLowerCase();
        if (!title.contains(query) && !description.contains(query)) {
          return false;
        }
      }

      // Price range filter
      if (_filterCriteria.priceRange != null) {
        if (product.variants.isEmpty) return false;
        final price = double.tryParse(product.variants[0].price.amount) ?? 0.0;
        if (price < _filterCriteria.priceRange!.start ||
            price > _filterCriteria.priceRange!.end) {
          return false;
        }
      }

      // Rating filter
      if (_filterCriteria.minRating != null && _filterCriteria.minRating! > 0) {
        if (product.avgRating < _filterCriteria.minRating!) return false;
      }

      // Brand filter
      if (_filterCriteria.selectedBrands?.isNotEmpty == true) {
        final hasMatchingBrand = _filterCriteria.selectedBrands!.any(
          (brand) => product.tags.any(
            (tag) => tag.toLowerCase().contains(brand.toLowerCase()),
          ),
        );
        if (!hasMatchingBrand) return false;
      }

      // Variant size filter
      if (_filterCriteria.selectedSizes?.isNotEmpty == true) {
        final hasMatchingSize = product.variants.any(
          (variant) => _filterCriteria.selectedSizes!.contains(variant.title),
        );
        if (!hasMatchingSize) return false;
      }

      // Category filter
      if (_filterCriteria.selectedCategories?.isNotEmpty == true) {
        final hasMatchingCategory = _filterCriteria.selectedCategories!.any(
          (category) => product.options.any(
            (opt) => opt.values.any(
              (val) => val.toLowerCase().contains(category.toLowerCase()),
            ),
          ),
        );
        if (!hasMatchingCategory) return false;
      }

      return true;
    }).toList();

    _applySortingToList(result);
    return result;
  }

  void _applySortingToList(List<ProductModel> list) {
    switch (_sortOption) {
      case SortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.priceLowToHigh:
        list.sort((a, b) {
          final priceA = a.variants.isNotEmpty
              ? double.tryParse(a.variants[0].price.amount) ?? 0.0
              : 0.0;
          final priceB = b.variants.isNotEmpty
              ? double.tryParse(b.variants[0].price.amount) ?? 0.0
              : 0.0;
          return priceA.compareTo(priceB);
        });
        break;
      case SortOption.priceHighToLow:
        list.sort((a, b) {
          final priceA = a.variants.isNotEmpty
              ? double.tryParse(a.variants[0].price.amount) ?? 0.0
              : 0.0;
          final priceB = b.variants.isNotEmpty
              ? double.tryParse(b.variants[0].price.amount) ?? 0.0
              : 0.0;
          return priceB.compareTo(priceA);
        });
        break;
      case SortOption.ratingHighToLow:
        list.sort((a, b) => b.avgRating.compareTo(a.avgRating));
        break;
      case SortOption.alphabeticalAZ:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case SortOption.alphabeticalZA:
        list.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
      case SortOption.popularity:
        list.sort((a, b) {
          if (a.avgRating != b.avgRating) {
            return b.avgRating.compareTo(a.avgRating);
          }
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        break;
      case SortOption.none:
        break;
    }
  }

  Future<void> _loadCustomerIdAndCartCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      customerId = prefs.getString('customer_id');
      if (customerId != null) {
        await fetchCartCount();
      }
    } catch (e) {
      debugPrint("Error loading customer ID and cart count: $e");
    }
  }

  Future<void> fetchCartCount() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://new-test.megascale.co.in/api/p1/cart?customer_id=$customerId',
        ),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['cart'] != null) {
          setState(() {
            cartItemCount = (data['cart'] as List).length;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching cart count: $e");
    }
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        margin: const EdgeInsets.only(top: 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AdvancedFilterWidget(
          currentFilters: _filterCriteria,
          currentSort: _sortOption,
          onFiltersChanged: (filters) {
            setState(() {
              _filterCriteria = filters;
            });
          },
          onSortChanged: (sort) {
            setState(() {
              _sortOption = sort;
            });
          },
          onFiltersCleared: () {
            setState(() {
              _filterCriteria = FilterCriteria();
              _sortOption = SortOption.none;
            });
          },
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          availableBrands: _availableBrands,
          availableSizes: _availableSizes,
          availableColors: _availableColors,
          availableCategories: _availableCategories,
        ),
      ),
    );
  }

  void _onSearchChangedApi() {
    _searchApiDebounce?.cancel();
    final query = searchController.text.trim();

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

  Widget _buildApiSearchResultGrid() {
    if (_isApiSearchLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromRGBO(111, 10, 15, 1),
            ),
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
                'No results for "${searchController.text.trim()}"',
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

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(111, 10, 15, 1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Search Results (${_apiSearchProducts.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final raw = _apiSearchProducts[index];

              // Use the SearchProduct model to normalize the data,
              // matching the working logic in SearchScreen.
              final searchProduct = SearchProduct.fromJson(
                Map<String, dynamic>.from(raw as Map),
              );

              return ProductCard(
                product: searchProduct.toProductCardMap(),
                isInitiallyInWishlist: false,
              );
            }, childCount: _apiSearchProducts.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2F2F2F)),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        searchController.clear();
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
            onChanged: (value) => setState(() {}),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _showAdvancedFilters,
                    icon: const Icon(Icons.filter_list, size: 20),
                    label: Text(
                      _filterCriteria.hasActiveFilters
                          ? (_sortOption != SortOption.none
                                ? 'Filtered'
                                : 'Filters')
                          : (_sortOption == SortOption.none
                                ? 'Sort & Filter'
                                : _sortOption.displayName),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _filterCriteria.hasActiveFilters
                          ? const Color.fromRGBO(111, 10, 15, 1)
                          : Colors.white,
                      foregroundColor: _filterCriteria.hasActiveFilters
                          ? Colors.white
                          : const Color.fromRGBO(111, 10, 15, 1),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _filterCriteria.hasActiveFilters
                              ? Colors.transparent
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_filterCriteria.hasActiveFilters ||
                  _sortOption != SortOption.none) ...[
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _filterCriteria.clearAll();
                        _sortOption = SortOption.none;
                      });
                    },
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(
    List<ProductModel> filteredList,
    bool isLoadingMore,
  ) {
    if (filteredList.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = filteredList[index];
              return ProductCard(
                product: product,
                isInitiallyInWishlist: false,
              );
            }, childCount: filteredList.length),
          ),
        ),
        if (isLoadingMore) const SliverToBoxAdapter(child: PaginationLoader()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Our Products",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                if (cartItemCount > 0)
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
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          cartItemCount.toString(),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ).then((_) => fetchCartCount()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isApiSearchActive || _isApiSearchLoading
                ? _buildApiSearchResultGrid()
                : Consumer<ProductProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.products.isEmpty) {
                        return const ProductShimmer();
                      }
                      if (provider.errorMessage != null &&
                          provider.products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error: ${provider.errorMessage}',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => provider.loadInitialProducts(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(
                                    111,
                                    10,
                                    15,
                                    1,
                                  ),
                                ),
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      // Populate filter options dynamically from loaded products
                      _updateFilterOptionFields(provider.products);
                      final filtered = _buildFilteredList(provider.products);
                      return _buildProductGrid(
                        filtered,
                        provider.isLoadingMore,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChangedApi);
    _searchApiDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
