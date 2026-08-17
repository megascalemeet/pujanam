import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pujanam/pages/categories/category_list_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/dummy/home_dummy_data.dart';
import '../products/product_list_screen.dart';

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

  final ScrollController _servedToGodController = ScrollController();
  final ScrollController _featuredProductsController = ScrollController();
  final Set<String> _wishlistedIds = {};

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController(viewportFraction: 0.9);
    _startBannerTimer();
    _simulateLoading();
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

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerPageController.hasClients) {
        final next = (_currentBannerIndex + 1) % HomeDummyData.bannerPosters.length;
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
      (controller.offset + offset).clamp(0, controller.position.maxScrollExtent),
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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
        title: Text(
          "BhagvatPrasadam",
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
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
                Icon(Icons.shopping_cart_outlined, color: Colors.white, size: iconSize),
                Positioned(
                  right: -8,
                  top: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: const Center(
                      child: Text(
                        "2",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
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
                Icon(Icons.notifications_none, color: Colors.white, size: iconSize),
                Positioned(
                  right: -8,
                  top: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: const Center(
                      child: Text(
                        "3",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromRGBO(111, 10, 15, 1)),
              child: Text(
                'BhagvatPrasadam',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
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
              Container(width: 70, height: 70, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
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
          children: List.generate(3, (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildContent(double screenWidth) {
    final bannerHeight = screenWidth < 400 ? 250.0 : 200.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10),
          _buildBannerCarousel(bannerHeight),
          const SizedBox(height: 16),
          _buildServedToGodSection(),
          const SizedBox(height: 16),
          _buildCategoriesSection(),
          const SizedBox(height: 16),
          _buildCelebrationsSection(),
          const SizedBox(height: 16),
          _buildBestSellersSection(),
          const SizedBox(height: 16),
          _buildOffersSection(),
          const SizedBox(height: 16),
          _buildFeaturedProductsSection(screenWidth),
          const SizedBox(height: 24),
          _buildDailyEssentialsSection(screenWidth),
          const SizedBox(height: 24),
          _buildHomeSection3(),
          const SizedBox(height: 24),
          _buildVideoSection(),
          const SizedBox(height: 32),
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
            child: GestureDetector(
              onTap: () {
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
                    const Icon(Icons.search, color: Color.fromRGBO(111, 10, 15, 1), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search products...',
                        style: TextStyle(color: Colors.grey[400], fontSize: 15, fontFamily: 'Poppins'),
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
    final posters = HomeDummyData.bannerPosters;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _bannerPageController,
              itemCount: posters.length,
              onPageChanged: (index) => setState(() => _currentBannerIndex = index),
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
                  child: Image.network(
                    posters[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
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
                  color: _currentBannerIndex == index ? const Color.fromRGBO(111, 10, 15, 1) : Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollButton({required IconData icon, required VoidCallback onPressed}) {
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
          child: Center(
            child: Icon(icon, size: 14, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildServedToGodSection() {
    final products = HomeDummyData.servedToGodProducts;
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
                    Text('EXCLUSIVE', style: TextStyle(color: Colors.grey[500], fontSize: 10, letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Serif'),
                        children: [
                          TextSpan(text: "Served To God, "),
                          TextSpan(text: "Perfected For You", style: TextStyle(color: Color.fromRGBO(111, 10, 15, 1))),
                        ],
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
              final imageSrc = product['media'][0]['previewSrc'].toString();
              final title = product['title'].toString();
              final price = product['variants'][0]['price'].toString();
              final compareAtPrice = product['variants'][0]['compareAtPrice']?.toString();
              final id = product['id'].toString();

              double discount = 0;
              if (compareAtPrice != null) {
                final original = double.tryParse(compareAtPrice) ?? 0;
                final current = double.tryParse(price) ?? 0;
                if (original > current && original > 0) {
                  discount = ((original - current) / original) * 100;
                }
              }

              return Container(
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
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                        if (discount > 0)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                'Sale -${discount.toInt()}%',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                              child: Icon(
                                _wishlistedIds.contains(id) ? Icons.favorite : Icons.favorite_border,
                                color: _wishlistedIds.contains(id) ? const Color.fromRGBO(111, 10, 15, 1) : Colors.grey,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "BHAGVATPRASADAM",
                      style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Color.fromRGBO(111, 10, 15, 1), size: 14),
                        Icon(Icons.star, color: Color.fromRGBO(111, 10, 15, 1), size: 14),
                        Icon(Icons.star, color: Color.fromRGBO(111, 10, 15, 1), size: 14),
                        Icon(Icons.star, color: Color.fromRGBO(111, 10, 15, 1), size: 14),
                        Icon(Icons.star, color: Color.fromRGBO(111, 10, 15, 1), size: 14),
                        SizedBox(width: 4),
                        Text("(10 reviews)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("On sale from Rs. $price", style: const TextStyle(fontSize: 14, color: Color.fromRGBO(111, 10, 15, 1))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    final categories = HomeDummyData.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                "Shop By Category",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: Colors.black87),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryListScreen(),));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Column(
                children: [
                  Container(
                    width: 95,
                    height: 95,
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
                      border: Border.all(color: const Color.fromRGBO(111, 10, 15, 0.1), width: 1),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        cat['image'].toString(),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[50],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 95,
                    child: Text(
                      cat['title'].toString(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
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

  Widget _buildCelebrationsSection() {
    final products = HomeDummyData.servedToGodProducts; // reuse dummy products
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 5, 12, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9D8BF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Celebrations',
                style: TextStyle(fontFamily: 'Serif', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFB8860B)),
              ),
              Spacer(),
              Row(
                children: [
                  Text('View All', style: TextStyle(color: Color(0xFF6F0A0F), fontWeight: FontWeight.w600)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 13, color: Color(0xFF6F0A0F)),
                ],
              ),
            ],
          ),
          const Text(
            'Festival Specials',
            style: TextStyle(fontFamily: 'Serif', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF6F0A0F)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(width: 58, child: Divider(color: Color(0xFFD4A72C), height: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(Icons.diamond, size: 14, color: Color(0xFFD4A72C)),
              ),
              SizedBox(width: 58, child: Divider(color: Color(0xFFD4A72C), height: 1)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 235,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                final price = product['variants'][0]['price'].toString();
                final title = product['title'].toString();
                final image = product['media'][0]['previewSrc'].toString();
                final id = product['id'].toString();

                return SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(image, height: 142, width: 150, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _toggleWishlist(id),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                                child: Icon(
                                  _wishlistedIds.contains(id) ? Icons.favorite : Icons.favorite_border,
                                  color: _wishlistedIds.contains(id) ? const Color.fromRGBO(111, 10, 15, 1) : Colors.grey,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      Text('₹$price', style: const TextStyle(color: Color(0xFF6F0A0F), fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestSellersSection() {
    final products = HomeDummyData.bestSellerProducts;

    Widget buildProductItem(Map<String, dynamic> product, {double offsetX = 0}) {
      final id = product['id'].toString();
      return Transform.translate(
        offset: Offset(offsetX, 0),
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
                    image: DecorationImage(image: NetworkImage(product['media'][0]['previewSrc'].toString()), fit: BoxFit.cover),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(id),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                      child: Icon(
                        _wishlistedIds.contains(id) ? Icons.favorite : Icons.favorite_border,
                        color: _wishlistedIds.contains(id) ? const Color.fromRGBO(111, 10, 15, 1) : Colors.grey,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              product['title'].toString(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            Text(
              "₹${product['variants'][0]['price']}",
              style: const TextStyle(fontSize: 10, color: Color.fromRGBO(111, 10, 15, 1), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Best Sellers',
            style: TextStyle(fontFamily: 'Serif', fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromRGBO(111, 10, 15, 1)),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 20, left: 16, right: 16),
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
              // Left Column
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildProductItem(products[0], offsetX: 35),
                    const SizedBox(height: 18),
                    buildProductItem(products[1], offsetX: 0),
                    const SizedBox(height: 18),
                    buildProductItem(products[2], offsetX: 35),
                  ],
                ),
              ),
              // Center Video Placeholder
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 250,
                    color: Colors.black12,
                    child: Stack(
                      alignment: Alignment.center,
                      children: const [
                        Icon(Icons.video_library_rounded, size: 50, color: Colors.grey),
                        Positioned(
                          bottom: 12,
                          child: Text("Bestsellers Video", style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              // Right Column
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildProductItem(products[3], offsetX: -35),
                    const SizedBox(height: 18),
                    buildProductItem(products[4], offsetX: 0),
                    const SizedBox(height: 18),
                    buildProductItem(products[5], offsetX: -35),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOffersSection() {
    final offer = HomeDummyData.offerSection;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [const Color.fromRGBO(111, 10, 15, 0.05), Colors.amber.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                offer['title'].toString(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.black87),
              ),
              const Row(
                children: [
                  Text('Shop Now', style: TextStyle(fontSize: 18, color: Color.fromRGBO(111, 10, 15, 1), fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Color.fromRGBO(111, 10, 15, 1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(offer['image'].toString(), width: double.infinity, height: 200, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.local_shipping_outlined, color: Color.fromRGBO(111, 10, 15, 1), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "LIMITED TIME OFFER",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.amber[800], letterSpacing: 1),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 15, color: Colors.black87, fontFamily: 'Poppins', height: 1.2),
                          children: [
                            TextSpan(text: "Free Shipping on orders above "),
                            TextSpan(text: "₹999", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color.fromRGBO(111, 10, 15, 1))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductsSection(double screenWidth) {
    final products = HomeDummyData.featuredProducts;
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
                "Featured Products",
                style: TextStyle(fontSize: screenWidth < 400 ? 20 : 24, fontWeight: FontWeight.bold),
              ),
              const Row(
                children: [
                  Text("View All", style: TextStyle(fontSize: 16, color: Color.fromRGBO(111, 10, 15, 1))),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Color.fromRGBO(111, 10, 15, 1)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: ListView.separated(
              controller: _featuredProductsController,
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                final price = product['variants'][0]['price'].toString();
                final compareAtPrice = product['variants'][0]['compareAtPrice']?.toString();
                final title = product['title'].toString();
                final image = product['media'][0]['previewSrc'].toString();
                final id = product['id'].toString();

                return Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(image, height: 200, width: double.infinity, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _toggleWishlist(id),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                                  child: Icon(
                                    _wishlistedIds.contains(id) ? Icons.favorite : Icons.favorite_border,
                                    color: _wishlistedIds.contains(id) ? const Color.fromRGBO(111, 10, 15, 1) : Colors.grey,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.2),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('₹$price', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromRGBO(111, 10, 15, 1))),
                                if (compareAtPrice != null) ...[
                                  const SizedBox(width: 4),
                                  Text('₹$compareAtPrice', style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyEssentialsSection(double screenWidth) {
    final products = HomeDummyData.dailyEssentials;
    final gridCrossAxisCount = screenWidth < 600 ? 2 : 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Daily Essentials", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridCrossAxisCount,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final price = product['variants'][0]['price'].toString();
              final compareAtPrice = product['variants'][0]['compareAtPrice']?.toString();
              final title = product['title'].toString();
              final image = product['media'][0]['previewSrc'].toString();
              final id = product['id'].toString();

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.network(image, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _toggleWishlist(id),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                                child: Icon(
                                  _wishlistedIds.contains(id) ? Icons.favorite : Icons.favorite_border,
                                  color: _wishlistedIds.contains(id) ? const Color.fromRGBO(111, 10, 15, 1) : Colors.grey,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins'), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('₹$price', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromRGBO(111, 10, 15, 1))),
                              if (compareAtPrice != null) ...[
                                const SizedBox(width: 4),
                                Text('₹$compareAtPrice', style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHomeSection3() {
    final section = HomeDummyData.homeSection3;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section['title'].toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.black87)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(section['image'].toString(), width: double.infinity, height: 250, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(section['description'].toString(), style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5, letterSpacing: 0.2)),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    final section = HomeDummyData.videoSection;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section['title'].toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.black87)),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: 200,
                  color: Colors.black54,
                  child: const Center(
                    child: Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
