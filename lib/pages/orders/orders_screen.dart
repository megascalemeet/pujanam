import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../models/orders/order_models.dart';
import '../../providers/orders/order_provider.dart';
import '../../providers/product/product_provider.dart';
import '../../models/product/add_review_model.dart';
import '../../services/product/product_api_service.dart';

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
      // Convert to UTC then add 5 hours and 30 minutes for IST
      DateTime istDate = date.toUtc().add(const Duration(hours: 5, minutes: 30));
      return DateFormat('dd MMM yyyy, hh:mm a').format(istDate);
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
      case 'delivered':
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
      final String customerId = prefs.getString('customer_id') ?? '';
      
      final int prodIdInt = int.tryParse(productId) ?? 0;
      
      final reviewModel = AddReviewModel(
        productId: prodIdInt,
        customerId: customerId,
        rating: rating,
        description: description,
      );

      if (!ctx.mounted) return;
      final productProvider = Provider.of<ProductProvider>(ctx, listen: false);
      final bool success = await productProvider.submitReview(reviewModel);

      if (success) {
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

  Widget _buildReviewQuickRow(Order order, {bool isSmallScreen = false}) {
    final String productId = order.items.isNotEmpty ? order.items[0].productId : '';

    return StatefulBuilder(
      builder: (context, setStateLocal) {
        int quickRating = 0;
        return Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 4, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We are glad you loved the product!',
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              if (productId.isNotEmpty)
                FutureBuilder<Map<String, dynamic>>(
                  future: _fetchReviewStats(productId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: primaryColor),
                          ),
                          const SizedBox(width: 8),
                          Text('Loading reviews...', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      );
                    }
                    if (snapshot.hasData) {
                      final double avgRating = (snapshot.data!['average_rating'] as num).toDouble();
                      final int reviewCount = snapshot.data!['review_count'] as int;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (reviewCount > 0)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ...List.generate(5, (i) {
                                  final double starVal = avgRating - i;
                                  IconData icon;
                                  if (starVal >= 1) {
                                    icon = Icons.star_rounded;
                                  } else if (starVal >= 0.5) {
                                    icon = Icons.star_half_rounded;
                                  } else {
                                    icon = Icons.star_outline_rounded;
                                  }
                                  return Icon(
                                    icon,
                                    color: Colors.amber[600],
                                    size: isSmallScreen ? 18 : 20,
                                  );
                                }),
                                // const SizedBox(width: 6),
                                // Text(
                                //   '${avgRating.toStringAsFixed(1)} ($reviewCount)',
                                //   style: TextStyle(
                                //     fontSize: isSmallScreen ? 11 : 12,
                                //     color: Colors.grey[600],
                                //     fontWeight: FontWeight.w500,
                                //   ),
                                // ),
                              ],
                            ),
                          if (reviewCount == 0) ...[ 
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ...List.generate(5, (i) {
                                  final starIndex = i + 1;
                                  return GestureDetector(
                                    onTap: () {
                                      setStateLocal(() => quickRating = starIndex);
                                      _showReviewSheet(order, productId: productId, initialRating: starIndex, isSmallScreen: isSmallScreen);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Icon(
                                        quickRating >= starIndex ? Icons.star_rounded : Icons.star_outline_rounded,
                                        color: quickRating >= starIndex ? Colors.amber[600] : Colors.grey[400],
                                        size: isSmallScreen ? 26 : 28,
                                      ),
                                    ),
                                  );
                                }),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _showReviewSheet(order, productId: productId, initialRating: quickRating, isSmallScreen: isSmallScreen),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      'Add Review',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 10 : 11,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchReviewStats(String productId) async {
    try {
      final summary = await ProductApiService().fetchProductReviewSummary(productId);
      
      double avg = 0.0;
      if (summary['avg_rating'] != null) {
        avg = double.tryParse(summary['avg_rating'].toString()) ?? 0.0;
      }
      
      int count = 0;
      if (summary['total_reviews'] != null) {
        count = int.tryParse(summary['total_reviews'].toString()) ?? 0;
      }

      return {
        'average_rating': avg,
        'review_count': count,
      };
    } catch (e) {
      debugPrint('[ReviewStats] Error: $e');
    }
    return {'average_rating': 0.0, 'review_count': 0};
  }

  void _showReviewSheet(
    Order order, {
    required String productId,
    int initialRating = 0,
    bool isSmallScreen = false,
  }) {
    final TextEditingController descController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        int rating = initialRating;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.rate_review_rounded, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Write a Review',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 15 : 17,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[600], size: 20,),
                          onPressed: () => Navigator.pop(sheetContext),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Share your experience with this product',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final starIndex = i + 1;
                        return GestureDetector(
                          onTap: () => setSheetState(() => rating = starIndex),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              child: Icon(
                                rating >= starIndex ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: rating >= starIndex ? Colors.amber[600] : Colors.grey[350],
                                size: isSmallScreen ? 36 : 42,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: descController,
                      maxLines: 4,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Your Review',
                        hintText: 'Tell others what you think...',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.chat_bubble_outline, color: primaryColor, size: 20),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (rating == 0) {
                                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                                    const SnackBar(content: Text('Please select a star rating.')),
                                  );
                                  return;
                                }
                                if (descController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                                    const SnackBar(content: Text('Please write your review.')),
                                  );
                                  return;
                                }
                                setSheetState(() => isSubmitting = true);
                                await _submitReview(
                                  productId: productId,
                                  rating: rating,
                                  description: descController.text.trim(),
                                  ctx: sheetContext,
                                );
                                if (sheetContext.mounted) Navigator.pop(sheetContext);
                              },
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          isSubmitting ? 'Submitting...' : 'Submit Review',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: isSmallScreen ? 13 : 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showOrderDetails(Order initialOrder) {
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
              child: FutureBuilder<Order?>(
                future: Provider.of<OrderProvider>(context, listen: false).fetchOrderDetails(initialOrder.id),
                builder: (context, snapshot) {
                  final order = snapshot.data ?? initialOrder;
                  final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
                  
                  return Column(
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
                        child: isLoading ? const Center(child: CircularProgressIndicator()) : ListView(
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
                            // Order Info Card
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
                                          'Order ${order.orderNumber}',
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
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            Text(
                              'Items',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            // Items List
                            ...order.items.map((item) => Container(
                                      margin: EdgeInsets.only(
                                          bottom: isSmallScreen ? 8 : 12),
                                      padding:
                                          EdgeInsets.all(isSmallScreen ? 8 : 12),
                                      decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.grey[200]!),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: isSmallScreen ? 50 : 60,
                                            height: isSmallScreen ? 50 : 60,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                    child: Image.network(
                                                      item.imageUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error,
                                                              stackTrace) =>
                                                          Icon(
                                                        Icons
                                                            .image_not_supported_outlined,
                                                        color: Colors.grey[400],
                                                        size:
                                                            isSmallScreen ? 20 : 24,
                                                      ),
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.shopping_bag_outlined,
                                                    color: Colors.grey[400],
                                                    size: isSmallScreen ? 20 : 24,
                                                  ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.title,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        isSmallScreen ? 13 : 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Qty: ${item.quantity}',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize:
                                                            isSmallScreen ? 12 : 13,
                                                      ),
                                                    ),
                                                    Text(
                                                      '₹${item.price}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize:
                                                            isSmallScreen ? 13 : 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            Text(
                              'Price Details',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[200]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _detailRow(
                                      'Subtotal',
                                      '₹${order.totalPrice}',
                                      isSmallScreen: isSmallScreen),
                                  _detailRow('Tax', '₹0.00',
                                      isSmallScreen: isSmallScreen),
                                  _detailRow('Shipping', 'Free',
                                      isSmallScreen: isSmallScreen),
                                  const Divider(height: 20, thickness: 1),
                                  _detailRow(
                                      'Total',
                                      '₹${order.totalPrice}',
                                      isTotal: true,
                                      isSmallScreen: isSmallScreen),
                                ],
                              ),
                            ),
                            Builder(
                              builder: (context) {
                                final bool isFulfilled = order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'completed' || order.status.toLowerCase() == 'paid';
                                
                                bool hasTracking = false;
                                if (order.latestShipment != null && order.latestShipment!.trackingNumber.isNotEmpty) {
                                  hasTracking = true;
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isFulfilled && !hasTracking) ...[
                                      SizedBox(height: isSmallScreen ? 16 : 20),
                                      Container(
                                        padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.orange.shade200),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.info_outline_rounded, color: Colors.orange[800], size: 24),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                order.status.toLowerCase() == 'pending' || order.status.toLowerCase() == 'processing'
                                                    ? "Your order is being prepared. Tracking details will be available once it is shipped. Please check again after 2 days."
                                                    : "Tracking information isn't available yet. Please check again after 2 days once your order has been shipped.",
                                                style: TextStyle(
                                                  color: Colors.orange[900],
                                                  fontSize: isSmallScreen ? 13 : 14,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: isSmallScreen ? 16 : 20),
                                    Text(
                                      'Shipping Information',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 8 : 12),
                                    Container(
                                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[200]!),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (order.shippingAddress != null) ...[
                                            Text(
                                              [
                                                order.shippingAddress!.addressLine1.trim(),
                                                order.shippingAddress!.addressLine2.trim(),
                                                order.shippingAddress!.city.trim(),
                                                order.shippingAddress!.state.trim(),
                                                order.shippingAddress!.pincode.trim(),
                                                order.shippingAddress!.country.trim(),
                                              ].where((s) => s.isNotEmpty).join(', '),
                                              style: TextStyle(
                                                fontSize: isSmallScreen ? 13 : 14,
                                              ),
                                            ),
                                          ],
                                          if (order.latestShipment != null && order.latestShipment!.carrier != null && order.latestShipment!.carrier!.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.local_shipping_outlined,
                                                    size: isSmallScreen ? 14 : 16,
                                                    color: Colors.grey[600]),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Carrier: ',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: isSmallScreen ? 12 : 14,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    order.latestShipment!.carrier!,
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
                                          if (order.latestShipment != null && order.latestShipment!.trackingNumber.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Icon(Icons.numbers_outlined,
                                                    size: isSmallScreen ? 14 : 16,
                                                    color: Colors.grey[600]),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Tracking #: ',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: isSmallScreen ? 12 : 14,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    order.latestShipment!.trackingNumber,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: isSmallScreen ? 12 : 14,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.content_copy,
                                                      size: isSmallScreen ? 16 : 18),
                                                  onPressed: () {
                                                    if (order.latestShipment!.trackingNumber.isNotEmpty) {
                                                      Clipboard.setData(ClipboardData(text: order.latestShipment!.trackingNumber));
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Tracking number copied to clipboard!')),
                                                      );
                                                    }
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (!isFulfilled && hasTracking) ...[
                                      const SizedBox(height: 30),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (order.latestShipment?.trackingUrl != null && order.latestShipment!.trackingUrl!.isNotEmpty) {
                                            final url = Uri.parse(order.latestShipment!.trackingUrl!);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url);
                                            } else {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Could not open tracking link.')),
                                                );
                                              }
                                            }
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Tracking details will be updated soon.'),
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
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
                                    ],
                                    const SizedBox(height: 20),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
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

    final bool isFulfilled = order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'completed' || order.status.toLowerCase() == 'paid';

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
                              'Order ${order.orderNumber}',
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
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.production_quantity_limits,
                                          size: isSmallScreen ? 14 : 16,
                                          color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Quantity: ${firstItem.quantity}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: isSmallScreen ? 12 : 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.calendar_today,
                              size: isSmallScreen ? 14 : 16,
                              color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Ordered on: ',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _formatDate(order.createdAt),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 24),
                    LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth < 280) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${order.totalPrice}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _showOrderDetails(order),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                child: const Text(
                                  'View Details',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${order.totalPrice}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 16 : 18,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () => _showOrderDetails(order),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 12 : 16,
                                    vertical: isSmallScreen ? 8 : 10),
                              ),
                              child: Text(
                                'View Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isFulfilled) ...[
          _buildReviewQuickRow(order, isSmallScreen: isSmallScreen),
          const SizedBox(height: 12),
        ],
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
