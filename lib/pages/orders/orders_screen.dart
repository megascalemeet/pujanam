import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../models/orders/order_models.dart';
import '../../providers/orders/order_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final primaryColor = const Color.fromRGBO(111, 10, 15, 1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return 'N/A';
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
      case 'confirmed':
      case 'success':
        return Colors.green[700]!;
      case 'pending':
      case 'processing':
        return Colors.orange[700]!;
      case 'cancelled':
      case 'failed':
      case 'refunded':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  List<Order> _getFilteredOrders(List<Order> allOrders) {
    if (_tabController.index == 0) {
      return allOrders;
    } else if (_tabController.index == 1) {
      return allOrders.where((order) {
        final st = order.status.toLowerCase();
        final pst = order.paymentStatus.toLowerCase();
        return st == 'completed' || st == 'confirmed' || st == 'success' || pst == 'paid';
      }).toList();
    } else {
      return allOrders.where((order) {
        final st = order.status.toLowerCase();
        final pst = order.paymentStatus.toLowerCase();
        return st == 'pending' || st == 'processing' || pst == 'pending';
      }).toList();
    }
  }

  Future<void> _submitReview({
    required String productId,
    required int rating,
    required String description,
    required BuildContext ctx,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String name = prefs.getString('name') ?? '';
      if (name.isEmpty) {
        final firstName = prefs.getString('firstName') ?? '';
        final lastName = prefs.getString('lastName') ?? '';
        name = '$firstName $lastName'.trim();
      }
      final email = prefs.getString('email') ?? '';

      final requestBody = json.encode({
        'product_id': productId,
        'rating': rating,
        'description': description,
        'name': name,
        'email': email,
      });

      final response = await http.post(
        Uri.parse('https://new-test.megascale.co.in/api/p1/addreview'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Review submitted successfully!'),
                ],
              ),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: const Text('Failed to submit review. Please try again.'),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: const Text('Error submitting review. Check your connection.'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildAddReviewSection(Order order, {bool isSmallScreen = false}) {
    final String productId = order.items.isNotEmpty ? order.id : '';
    int selectedRating = 0;
    final TextEditingController descController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setStateLocal) {
        return Container(
          margin: const EdgeInsets.only(top: 4),
          padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withValues(alpha: 0.04),
                Colors.amber.withValues(alpha: 0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.rate_review_rounded, color: primaryColor, size: isSmallScreen ? 18 : 20),
                  const SizedBox(width: 8),
                  Text(
                    'Write a Review',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 17,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setStateLocal(() {
                        selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience with this order...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedRating == 0
                      ? null
                      : () async {
                          await _submitReview(
                            productId: productId,
                            rating: selectedRating,
                            description: descController.text,
                            ctx: context,
                          );
                          descController.clear();
                          setStateLocal(() {
                            selectedRating = 0;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Submit Review'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOrderDetails(Order order) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    final double initialChildSize = screenHeight < 700 ? 0.95 : 0.85;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order Details',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 20 : 22,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.grey[700]),
                              onPressed: () => Navigator.pop(context),
                              iconSize: isSmallScreen ? 20 : 24,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Order #${order.orderNumber}',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order.status).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(order.status),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          order.status.toUpperCase(),
                                          style: TextStyle(
                                            color: _getStatusColor(order.status),
                                            fontSize: isSmallScreen ? 10 : 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: isSmallScreen ? 14 : 16,
                                      color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ordered on: ',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _formatDate(order.createdAt),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Items Ordered',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.items.length,
                          itemBuilder: (context, index) {
                            final item = order.items[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              item.imageUrl!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(
                                            Icons.shopping_bag_outlined,
                                            color: Colors.grey[400],
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Qty: ${item.quantity}',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${order.currency} ${item.price}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Divider(height: 30),
                        _detailRow('Subtotal', '${order.currency} ${order.totalPrice}', isSmallScreen: isSmallScreen),
                        _detailRow('Shipping', 'Free', isSmallScreen: isSmallScreen),
                        _detailRow('Total', '${order.currency} ${order.totalPrice}', isTotal: true, isSmallScreen: isSmallScreen),
                        const SizedBox(height: 25),
                        _buildAddReviewSection(order, isSmallScreen: isSmallScreen),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tracking details will be updated soon.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Track Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value,
      {bool isTotal = false, required bool isSmallScreen}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.grey[600],
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    final firstItem = order.items.isNotEmpty ? order.items[0] : null;
    final statusColor = _getStatusColor(order.status);
    final String imageUrl = firstItem?.imageUrl ?? '';

    final double imageSize = isSmallScreen ? 60 : 70;
    final double fontSize = isSmallScreen ? 13 : 14;
    final double padding = isSmallScreen ? 12 : 16;

    final bool isFulfilled = order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'completed';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: isFulfilled ? 8 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showOrderDetails(order),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Text(
                              'Order #${order.orderNumber}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize,
                                color: primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: isSmallScreen ? 10 : 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (firstItem != null) ...[
                      LayoutBuilder(builder: (context, constraints) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: imageSize,
                              height: imageSize,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Colors.grey[400],
                                          size: 30,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.shopping_bag_outlined,
                                      color: Colors.grey[400],
                                      size: 30,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    firstItem.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${order.items.length} items',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: isSmallScreen ? 11 : 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${order.currency} ${order.totalPrice}',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 15 : 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(order.createdAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final List<CartItemInput> cartInputs = order.items.map((item) {
                              return CartItemInput(
                                productId: order.id,
                                variantId: order.id,
                                price: double.tryParse(item.price) ?? 0.0,
                                quantity: item.quantity,
                                sku: 'REORDER-${order.orderNumber}',
                                title: item.title,
                              );
                            }).toList();

                            final success = await Provider.of<OrderProvider>(context, listen: false)
                                .reorderItems(cartInputs);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success ? 'Added items to cart successfully!' : 'Failed to reorder items',
                                  ),
                                  backgroundColor: success ? Colors.green : Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Buy Again'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Orders',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: primaryColor,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.tab,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Completed'),
                Tab(text: 'Pending'),
              ],
            ),
          ),
          Expanded(
            child: orderProvider.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  )
                : _getFilteredOrders(orderProvider.orders).isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your order history will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MainNavigationScreen()),
                                );
                              },
                              icon: const Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Continue Shopping',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(111, 10, 15, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: orderProvider.fetchOrders,
                        color: primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _getFilteredOrders(orderProvider.orders).length,
                          itemBuilder: (context, index) {
                            return _buildOrderCard(_getFilteredOrders(orderProvider.orders)[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
