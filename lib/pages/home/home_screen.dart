import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pujanam/pages/categories/category_list_screen.dart';
import 'package:pujanam/pages/categories/category_product_list_screen.dart';
import 'package:pujanam/theme/app_color.dart';
import 'package:pujanam/widgets/drawer/custom_drawer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import '../../models/product/product_response_model.dart';
import '../../providers/category/category_provider.dart';
import '../../providers/product/product_provider.dart';
import '../products/product_detail_screen.dart';
import '../products/product_list_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _bannerPageController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;
  bool _isLoading = true;
  // Local banner asset image paths
  final List<String> _bannerImages = const [
    'assets/images/homepage_banner_1.png',
    'assets/images/homepage_banner_2.png',
    'assets/images/homepage_banner_3.png',
  ];
  final ScrollController _servedToGodController = ScrollController();
  final ScrollController _featuredProductsController = ScrollController();
  final Set<String> _wishlistedIds = {};

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController(viewportFraction: 0.9);
    _startBannerTimer();
    _simulateLoading();

    // Fetch perfume products for Home "Served To God" section
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadInitialProducts();
      context.read<ProductProvider>().loadBestSellerProducts();
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      provider.fetchPerfumeProducts();
      provider.loadCategories();
    });
  }

  void _simulateLoading() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Add this field with your other fields
  final Map<String, bool> _isAddingToWishlist = {};

  // Add this method to build star rating
  Widget _buildStarRating(double rating, {double size = 14}) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: Colors.amber, size: size);
        } else if (index < rating) {
          return Icon(Icons.star_half, color: Colors.amber, size: size);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: size);
        }
      }),
    );
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerPageController.hasClients) {
        final next = (_currentBannerIndex + 1) % _bannerImages.length;
        _bannerPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    _servedToGodController.dispose();
    _featuredProductsController.dispose();
    super.dispose();
  }

  void _toggleWishlist(String id) {
    setState(() {
      if (_wishlistedIds.contains(id)) {
        _wishlistedIds.remove(id);
      } else {
        _wishlistedIds.add(id);
      }
    });
  }

  void _scrollList(ScrollController controller, double offset) {
    if (!controller.hasClients) return;
    controller.animateTo(
      (controller.offset + offset).clamp(
        0,
        controller.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = screenWidth * 0.048;
    titleFontSize = titleFontSize.clamp(14, 22);

    double iconSize = screenWidth * 0.065;
    iconSize = iconSize.clamp(20, 28);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const CustomDrawer(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: Text(
          "Shree Nilkanth Store",
          // "BhagvatPrasadam",
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: iconSize,
                ),
                Positioned(
                  right: -8,
                  top: -10,
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
                    child: const Center(
                      child: Text(
                        "2",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: iconSize,
                ),
                Positioned(
                  right: -8,
                  top: -10,
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
                    child: const Center(
                      child: Text(
                        "3",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isLoading = true;
          });
          _simulateLoading();
        },
        color: const Color.fromRGBO(111, 10, 15, 1),
        child: _isLoading ? _buildShimmerView() : _buildContent(screenWidth),
      ),
    );
  }

  Widget _buildShimmerView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildShimmerBanner(),
          const SizedBox(height: 24),
          _buildShimmerCategories(),
          const SizedBox(height: 24),
          _buildShimmerProducts(),
        ],
      ),
    );
  }

  Widget _buildShimmerBanner() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  Widget _buildShimmerCategories() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: 130,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, __) => Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Container(width: 60, height: 10, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerProducts() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 260,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(double screenWidth) {
    final bannerHeight = screenWidth < 400 ? 350.0 : 300.0;
    //400 ? 250.0 : 200.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10),
          _buildBannerCarousel(bannerHeight),
          const SizedBox(height: 16),
          _buildNewArrivals(),
          const SizedBox(height: 0),
          _buildCategoriesSection(),
          const SizedBox(height: 16),
          // _buildCelebrationsSection(),
          // const SizedBox(height: 16),
          _buildBestSellersSection(),
          // const SizedBox(height: 5),
          _buildFeaturedProductsSection(screenWidth),
          _buildHomeSection3(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
                //.then((_) => fetchCartCount());
              },
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.search,
                      color: Color.fromRGBO(111, 10, 15, 1),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search products...',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 15,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel(double height) {
    final posters = _bannerImages;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _bannerPageController,
              itemCount: posters.length,
              onPageChanged: (index) =>
                  setState(() => _currentBannerIndex = index),
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    height: 400,
                    posters[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              posters.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentBannerIndex == index
                      ? const Color.fromRGBO(111, 10, 15, 1)
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(child: Icon(icon, size: 14, color: Colors.black)),
        ),
      ),
    );
  }

  Widget _buildNewArrivals() {
    final provider = context.watch<CategoryProvider>();
    final products = provider.perfumeProducts;
    // Loading state - show nothing (shimmer already handled by overall _isLoading)
    if (provider.isProductsLoading) {
      return const SizedBox(
        height: 310,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    // Empty state - hide section
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "New Arrivals",
                      //'EXCLUSIVE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,

                        //  fontFamily: 'Serif',
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildScrollButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => _scrollList(_servedToGodController, -300),
                  ),
                  const SizedBox(width: 8),
                  _buildScrollButton(
                    icon: Icons.arrow_forward_ios,
                    onPressed: () => _scrollList(_servedToGodController, 300),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 310,
          child: ListView.builder(
            controller: _servedToGodController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final imageSrc = product.imageUrl ?? '';
              final rating = product.avgRating;
              final title = product.title;
              final reviewCount = product.totalReviews;
              final price = product.price.toString();
              final compareAtPrice = product.compareAtPrice > 0
                  ? product.compareAtPrice.toString()
                  : null;
              final id = product.id;

              double discount = 0;
              if (compareAtPrice != null) {
                final original = double.tryParse(compareAtPrice) ?? 0;
                final current = double.tryParse(price) ?? 0;
                if (original > current && original > 0) {
                  discount = ((original - current) / original) * 100;
                }
              }

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
                  width: 180,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageSrc,
                              height: 180,
                              width: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 180,
                                width: 180,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          if (discount > 0)
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Sale -${discount.toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () => _toggleWishlist(id),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _wishlistedIds.contains(id)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _wishlistedIds.contains(id)
                                      ? const Color.fromRGBO(111, 10, 15, 1)
                                      : Colors.grey,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Shree Nilkanth Store",
                        //"BHAGVATPUJNAM",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Row(
                        children: [
                          ...List.generate(5, (starIndex) {
                            if (starIndex < rating.floor()) {
                              return const Icon(
                                Icons.star,
                                color: Color.fromRGBO(111, 10, 15, 1),
                                size: 14,
                              );
                            }
                            if (starIndex < rating) {
                              return const Icon(
                                Icons.star_half,
                                color: Color.fromRGBO(111, 10, 15, 1),
                                size: 14,
                              );
                            }
                            return const Icon(
                              Icons.star_border,
                              color: Color.fromRGBO(111, 10, 15, 1),
                              size: 14,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            "($reviewCount reviews)",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "On sale from Rs. $price",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromRGBO(111, 10, 15, 1),
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
    );
  }

  Widget _buildCategoriesSection() {
    final categories = context.watch<CategoryProvider>().categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                "Shop By Collection",
                style: TextStyle(
                  fontSize: 24,
                  //fontSize: 24,
                  fontWeight: FontWeight.w500,
                  //fontWeight: FontWeight.bold,
                  //fontFamily: 'Serif',
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryListScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 155,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryProductListScreen(
                            title: cat.title,
                            handle: cat.handle,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color.fromRGBO(111, 10, 15, 0.1),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: cat.imageUrl != null
                            ? Image.network(
                                cat.imageUrl!,
                                fit: BoxFit.contain,
                                // width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(Icons.image_not_supported),
                                    ),
                              )
                            : const Center(
                                child: Icon(Icons.category, size: 40),
                              ),
                        // Image.network(
                        //   cat.imageUrl ?? '',
                        //   fit: BoxFit.contain,
                        //   errorBuilder: (_, __, ___) => Container(
                        //     color: Colors.grey[50],
                        //     child: const Icon(
                        //       Icons.image_not_supported,
                        //       color: Colors.grey,
                        //     ),
                        //   ),
                        // ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 95,
                    child: Text(
                      cat.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        // fontSize: 11,
                        // fontWeight: FontWeight.w600,
                        // color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBestSellersSection() {
    final provider = context.watch<ProductProvider>();
    final isLoading = provider.isBestSellerLoading;
    final errorMessage = provider.bestSellerErrorMessage;
    final products = provider.bestSellerProducts;

    // Show loading state
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(111, 10, 15, 1),
          ),
        ),
      );
    }

    // Show error state
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Text(
          'Error loading best sellers: $errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // Hide section if no products
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get 6 products for best seller section
    final validProducts = products.take(6).toList();
    if (validProducts.length < 6) {
      return const SizedBox.shrink();
    }

    // Build product item widget
    Widget _buildProductItem(ProductModel product, {double offsetX = 0}) {
      final id = product.id;
      final imageUrl = product.imageUrl ?? '';
      final title = product.title;
      final price = product.variants.isNotEmpty
          ? product.variants[0].price.amount
          : '0';

      return Transform.translate(
        offset: Offset(offsetX, 0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  // Wishlist button on top right
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _toggleWishlist(id),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _wishlistedIds.contains(id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _wishlistedIds.contains(id)
                              ? const Color.fromRGBO(111, 10, 15, 1)
                              : Colors.grey,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '₹${double.tryParse(price)?.toInt() ?? 0}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color.fromRGBO(111, 10, 15, 1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Best Sellers',
            style: TextStyle(
              // fontFamily: 'Serif',
              fontSize: 24,
              //fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            top: 8,
            bottom: 20,
            left: 16,
            right: 16,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left Column - 3 products with offset
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProductItem(validProducts[0], offsetX: 35),
                    const SizedBox(height: 18),
                    _buildProductItem(validProducts[1], offsetX: 0),
                    const SizedBox(height: 18),
                    _buildProductItem(validProducts[2], offsetX: 35),
                  ],
                ),
              ),
              // Center Video Player
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const PremiumVideoPlayer(
                    videoUrl:
                        'https://cdn.shopify.com/videos/c/o/v/c379f85e313c48eaa0a0d7648bb0a58c.mp4',
                  ),
                ),
              ),
              // Right Column - 3 products with offset
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProductItem(validProducts[3], offsetX: -35),
                    const SizedBox(height: 18),
                    _buildProductItem(validProducts[4], offsetX: 0),
                    const SizedBox(height: 18),
                    _buildProductItem(validProducts[5], offsetX: -35),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProductsSection(double screenWidth) {
    // Get products from provider - use watch to listen for changes
    final products = context.watch<ProductProvider>().products;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Top Month Sellers",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductListScreen(
                        title: 'All Products',
                        collectionId: "",
                      ),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(111, 10, 15, 1),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color.fromRGBO(111, 10, 15, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Show loading indicator while products are being fetched
          context.watch<ProductProvider>().isLoading
              ? const SizedBox(
                  height: 260,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(111, 10, 15, 1),
                    ),
                  ),
                )
              : products.isEmpty
              ? const SizedBox(
                  height: 260,
                  child: Center(
                    child: Text(
                      'No products available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              : SizedBox(
                  height: 280,
                  child: ListView.separated(
                    controller: _featuredProductsController,
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length > 10 ? 10 : products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final product = products[index];

                      // Check if product has variants and media
                      if (product.variants.isEmpty ||
                          product.imageUrl.isEmpty) {
                        return Container(
                          width: 160,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      // Get the price values as strings and parse to double
                      final priceStr = product.variants[0].price.amount;
                      final compareAtStr =
                          product.variants[0].compareAtPrice?.amount;

                      final priceAmount = double.tryParse(priceStr) ?? 0.0;
                      final compareAtAmount =
                          double.tryParse(compareAtStr ?? '') ?? 0.0;

                      final title = product.title;
                      final image = product.imageUrl;
                      final id = product.id;

                      // Calculate discount percentage if compareAtPrice exists
                      bool hasDiscount =
                          compareAtAmount > 0 && compareAtAmount > priceAmount;
                      int discountPercent = 0;
                      if (hasDiscount) {
                        discountPercent =
                            ((compareAtAmount - priceAmount) /
                                    compareAtAmount *
                                    100)
                                .round();
                      }

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 160,
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
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                      child: Image.network(
                                        image,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.error,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035 - 2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              priceAmount > 0
                                                  ? '₹${priceAmount.toStringAsFixed(0)}'
                                                  : 'Price-',
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                                color: const Color.fromRGBO(
                                                  111,
                                                  10,
                                                  15,
                                                  1,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (compareAtAmount >
                                                priceAmount) ...[
                                              const SizedBox(width: 4),
                                              Text(
                                                '₹${compareAtAmount.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  fontSize:
                                                      screenWidth * 0.035 - 4,
                                                  color: Colors.grey[600],
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFE8F5E8,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '$discountPercent% OFF',
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.035 - 4,
                                                    color: const Color(
                                                      0xFF2E7D32,
                                                    ),
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
                                            _buildStarRating(
                                              product.avgRating ?? 0,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${product.totalReviews ?? 0})',
                                              style: TextStyle(
                                                fontSize:
                                                    screenWidth * 0.035 - 4,
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
                              // % OFF Label - Top Left
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
                                  onTap: () => _toggleWishlist(id),
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
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Color.fromRGBO(
                                                      111,
                                                      10,
                                                      15,
                                                      1,
                                                    ),
                                                  ),
                                            ),
                                          )
                                        : Icon(
                                            _wishlistedIds.contains(id)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: _wishlistedIds.contains(id)
                                                ? const Color.fromRGBO(
                                                    111,
                                                    10,
                                                    15,
                                                    1,
                                                  )
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
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHomeSection3() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   "Pooja Saman",
          //   style: TextStyle(
          //     fontSize: 12,
          //     fontWeight: FontWeight.bold,
          //     fontFamily: 'Poppins',
          //     color: Color(0xFFEBD99C),
          //     //Colors.black87,
          //   ),
          // ),
          // const SizedBox(height: 4),
          Text(
            "Decorate Your Mandir with Shri Nilkanth Store",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: AppColors.primary,
              //Color.fromRGBO(111, 10, 15, 0.7),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/homepage_image.webp',
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: Text('Image not available')),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "At Shri Nilkanth Store, we bring divinity closer to your home. Our handpicked spiritual products are designed to elevate your pooja space with purity, tradition, and grace. Each item is crafted with care — blending age-old rituals with modern aesthetics for your sacred moments.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class PremiumVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const PremiumVideoPlayer({super.key, required this.videoUrl});

  @override
  _PremiumVideoPlayerState createState() => _PremiumVideoPlayerState();
}

class _PremiumVideoPlayerState extends State<PremiumVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.network(
            widget.videoUrl,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
          ..initialize()
              .then((_) {
                if (mounted) {
                  setState(() {
                    _initialized = true;
                    _controller.setLooping(true);
                    _controller.setVolume(0.0);
                    _controller.play();
                  });
                }
              })
              .catchError((error) {
                if (mounted) {
                  setState(() {
                    _hasError = true;
                  });
                }
              });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Icon(Icons.error_outline, color: Colors.red, size: 40),
      );
    }
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: Color.fromRGBO(111, 10, 15, 1)),
      );
    }
    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
