import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../products/product_list_screen.dart';

class Message {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String content;
  final String sentAt;
  final String link;
  bool isRead;

  Message({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.content,
    required this.sentAt,
    this.link = '',
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    String rawImageUrl = json['imageUrl']?.toString() ?? '';
    String dateStr =
        json['sentAt']?.toString() ??
        json['createdAt']?.toString() ??
        'Not Available';

    return Message(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'No Title',
      description: json['description']?.toString() ?? 'No Description',
      imageUrl: rawImageUrl,
      content: json['content']?.toString() ?? 'No Content',
      link: json['link']?.toString() ?? '',
      sentAt: dateStr,
      isRead: json['isRead'] == true,
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Message>> futureMessages;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureMessages = fetchMessages();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List<Message>> fetchMessages() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      String? customerId = prefs.getString('customer_id');

      final RegExp mongoIdRegex = RegExp(r'^[a-fA-F0-9]{24}$');
      final String userId =
          (customerId != null &&
              customerId.trim().isNotEmpty &&
              mongoIdRegex.hasMatch(customerId.trim()))
          ? customerId.trim()
          : '6a20fd9e11065cbe1cbfd67c';

      final url = Uri.parse(
        'https://new-test.megascale.co.in/api/p1/notifications/$userId',
      );

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Connection timed out. Please try again.');
            },
          );

      if (response.statusCode == 200) {
        final dynamic bodyData = json.decode(response.body);

        List<dynamic> messageList = [];
        if (bodyData is Map<String, dynamic>) {
          if (bodyData['notifications'] is List) {
            messageList = bodyData['notifications'];
          } else if (bodyData['messages'] is List) {
            messageList = bodyData['messages'];
          } else if (bodyData['data'] is List) {
            messageList = bodyData['data'];
          }
        } else if (bodyData is List) {
          messageList = bodyData;
        }

        final List<Message> messages = [];
        for (var jsonItem in messageList) {
          if (jsonItem is Map<String, dynamic>) {
            final message = Message.fromJson(jsonItem);
            message.isRead =
                (prefs.getBool('notification_${message.id}') ?? false) ||
                message.isRead;
            messages.add(message);
          }
        }

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return messages;
      } else if (response.statusCode == 500) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return [];
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        throw Exception(
          'Failed to load notifications (Server returned status code: ${response.statusCode})',
        );
      }
    } on SocketException {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      throw Exception(
        'No Internet connection. Please check your network and try again.',
      );
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      throw Exception(e.message ?? 'Request timed out. Please try again.');
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      throw Exception(
        'Error loading notifications: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  Future<void> markAsRead(String messageId) async {
    if (messageId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_$messageId', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        color: const Color.fromRGBO(111, 10, 15, 1),
        backgroundColor: Colors.white,
        strokeWidth: 3,
        onRefresh: () async {
          if (mounted) {
            setState(() {
              // futureMessages = fetchMessages();
            });
            _animationController.reset();
            _animationController.forward();
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'You don\'t have any notifications yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ),
        // FutureBuilder<List<Message>>(
        //   future: futureMessages,
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return _buildLoadingState();
        //     } else if (snapshot.hasError) {
        //       return _buildErrorState(snapshot.error);
        //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        //       return _buildEmptyState();
        //     }
        //     final messages = snapshot.data!;
        //     return FadeTransition(
        //       opacity: _fadeAnimation,
        //       child: ListView.builder(
        //         padding: const EdgeInsets.all(16.0),
        //         itemCount: messages.length,
        //         itemBuilder: (context, index) {
        //           final message = messages[index];
        //           return _buildNotificationCard(context, message, index);
        //         },
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    Message message,
    int index,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool hasValidImage =
        message.imageUrl.trim().isNotEmpty &&
        message.imageUrl.startsWith('http') &&
        !message.imageUrl.contains('via.placeholder.com');

    return AnimatedBuilder(
      animation: _animationController,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            await markAsRead(message.id);
            message.isRead = true;
            if (mounted) {
              setState(() {});
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductListScreen(
                  title: message.title,
                  collectionId: message.id,
                ),
              ),
            ).then((_) {
              if (mounted) {
                setState(() {});
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'image-${message.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: hasValidImage
                          ? CachedNetworkImage(
                              imageUrl: message.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: const Color.fromRGBO(
                                    111,
                                    10,
                                    15,
                                    0.08,
                                  ),
                                  child: const Icon(
                                    Icons.notifications,
                                    size: 36,
                                    color: Color.fromRGBO(111, 10, 15, 1),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: const Color.fromRGBO(111, 10, 15, 0.08),
                              child: const Icon(
                                Icons.notifications,
                                size: 36,
                                color: Color.fromRGBO(111, 10, 15, 1),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                message.title,
                                style: TextStyle(
                                  fontWeight: message.isRead
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!message.isRead)
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color.fromRGBO(111, 10, 15, 1),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent,
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDate(message.sentAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(
                                  111,
                                  10,
                                  15,
                                  1,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "View Details",
                                    style: TextStyle(
                                      fontSize: screenWidth < 400 ? 14 : 16,
                                      color: const Color.fromRGBO(
                                        111,
                                        10,
                                        15,
                                        1,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: screenWidth < 400 ? 12 : 14,
                                    color: const Color.fromRGBO(111, 10, 15, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      builder: (context, child) {
        final delay = index * 0.05;
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0.0, 0.25),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  delay.clamp(0.0, 0.8),
                  (delay + 0.4).clamp(0.0, 1.0),
                  curve: Curves.easeOutQuad,
                ),
              ),
            );
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay.clamp(0.0, 0.8),
              (delay + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOutQuad,
            ),
          ),
        );
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromRGBO(111, 10, 15, 1),
              ),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    String errorMessage = error != null
        ? error.toString().replaceAll('Exception: ', '')
        : 'Could not connect to the notification server. Please check your connection and try again.';

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.signal_wifi_off_rounded,
                size: 80,
                color: Color.fromRGBO(111, 10, 15, 1),
              ),
              const SizedBox(height: 16),
              Text(
                'Connection Problem',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      futureMessages = fetchMessages();
                    });
                    _animationController.reset();
                    _animationController.forward();
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'You don\'t have any notifications yet. Check back later for updates.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(String sentAt) {
    if (sentAt.isEmpty || sentAt == 'Not Available') {
      return 'Not Available';
    }
    try {
      final date = DateTime.parse(sentAt);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes < 5) {
            return 'Just now';
          } else {
            return '${difference.inMinutes} min ago';
          }
        } else {
          return '${difference.inHours} hours ago';
        }
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return sentAt;
    }
  }
}
