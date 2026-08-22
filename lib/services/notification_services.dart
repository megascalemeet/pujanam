import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:pujanam/pages/categories/category_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../pages/products/product_detail_screen.dart';

class NotificationServices {
  static final NotificationServices _instance =
  NotificationServices._internal();
  factory NotificationServices() => _instance;
  NotificationServices._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  BuildContext? _context;

  Future<void> initialize({BuildContext? context}) async {
    _context = context;
    print(
      'Initializing NotificationServices with context: ${_context != null}',
    );
    await _initializeLocalNotifications();
    await _configureFirebaseMessaging();
  }

  void updateContext(BuildContext context) {
    _context = context;
    print('Updated context for NotificationServices');
  }

  Future<void> _initializeLocalNotifications() async {
    print('Initializing local notifications');
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    ); // Changed to launcher_icon
    const DarwinInitializationSettings iosInitSettings =
    DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    try {
      bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification tapped with payload: ${response.payload}');
          _handleMessageFromPayload(response.payload);
        },
      );
      print('Local notifications initialized: $initialized');
    } catch (e) {
      print('Error initializing local notifications: $e');
    }
  }

  Future<void> _configureFirebaseMessaging() async {
    print('Configuring Firebase Messaging');
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('Notification permission status: ${settings.authorizationStatus}');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received: ${message.notification?.title}');
        print('Message data: ${message.data}');
        print('Notification: ${message.notification?.toMap()}');
        _showNotification(message);
        _showPopupNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notification opened: ${message.notification?.title}');
        print('Opened message data: ${message.data}');
        print('Opened notification payload: ${message.notification?.toMap()}');
        _handleMessage(message);
      });

      final RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        print(
          'App opened from notification: ${initialMessage.notification?.title}',
        );
        print('Initial message data: ${initialMessage.data}');
        print(
          'Initial notification payload: ${initialMessage.notification?.toMap()}',
        );
        _handleMessage(initialMessage);
      }
    } catch (e) {
      print('Error configuring Firebase Messaging: $e');
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    print('Attempting to show local notification');
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'High importance notifications',
      importance: Importance.high,
    );

    try {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
      >()
          ?.createNotificationChannel(channel);
      print('Notification channel created: ${channel.id}');

      final AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon', // Changed to launcher_icon
        playSound: true,
        enableVibration: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      final payload = jsonEncode({
        'id': message.messageId,
        'title':
        message.notification?.title ?? message.data['title'] ?? 'No Title',
        'body': message.notification?.body ?? message.data['body'] ?? 'No Body',
        'link': message.data['link'],
        'orderId': message.data['body']
            ?.toString()
            .split('is ')
            .last, // Extract order ID
      });

      await _flutterLocalNotificationsPlugin.show(
        id: message.messageId.hashCode,
        title:
        message.notification?.title ??
            message.data['title'] ??
            'Notification',
        body:
        message.notification?.body ?? message.data['body'] ?? 'New message',
        notificationDetails: notificationDetails,
        payload: payload,
      );
      print('Local notification shown successfully');
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  void _showPopupNotification(RemoteMessage message) {
    final BuildContext? activeContext = _context ?? navigatorKey.currentContext;
    if (activeContext == null) {
      print('Context is null, cannot show pop-up');
      return;
    }

    print('Showing pop-up notification');
    final String title =
        message.notification?.title ??
            message.data['title'] ??
            'New Notification';
    final String body =
        message.notification?.body ??
            message.data['body'] ??
            'No details available';
    final String? orderId = message.data['body']?.toString().split('is ').last;
    final String? link = message.data['link'];
    final bool hasLink = link != null && link.isNotEmpty;

    try {
      showDialog(
        context: activeContext,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Color.fromRGBO(111, 10, 15, 1),
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(111, 10, 15, 1),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        print('Dismiss button pressed');
                        Navigator.pop(dialogContext);
                      },
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(color: Color.fromRGBO(111, 10, 15, 1)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print('View button pressed. Link: $link');
                        Navigator.pop(dialogContext);
                        if (hasLink) {
                          _handleLinkNavigation(link);
                        } else {
                          // Default action if no link (like viewing orders)
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        hasLink ? 'View' : 'View Order',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      print('Pop-up dialog shown');
    } catch (e) {
      print('Error showing pop-up notification: $e');
    }
  }

  void _handleMessage(RemoteMessage message) {
    print('Handling message: ${message.notification?.title}');
    final String? link = message.data['link'];
    if (link != null && link.isNotEmpty) {
      _handleLinkNavigation(link);
    }
  }

  void _handleMessageFromPayload(String? payload) {
    if (payload == null) {
      print('Payload is null, cannot handle payload');
      return;
    }

    print('Handling payload: $payload');
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      final String? link = data['link'];
      if (link != null && link.isNotEmpty) {
        _handleLinkNavigation(link);
      }
    } catch (e) {
      print('Error handling payload: $e');
    }
  }

  Future<void> _handleLinkNavigation(String link) async {
    final context = navigatorKey.currentContext ?? _context;
    if (context == null) {
      print('No context available for navigation');
      return;
    }

    try {
      final uri = Uri.tryParse(link);
      if (uri == null) return;

      final pathSegments = uri.pathSegments;

      // 1. Check for product link
      final productsIndex = pathSegments.indexOf('products');
      final productIndex = pathSegments.indexOf('product');
      final targetIndex = productsIndex != -1 ? productsIndex : productIndex;
      if (targetIndex != -1 && targetIndex + 1 < pathSegments.length) {
        final String handle = pathSegments[targetIndex + 1];
        print('Extracted product handle from URL: $handle');

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailScreen(product: {'handle': handle}),
          ),
        );
        return;
      }

      // 2. Check for collection link
      final collectionsIndex = pathSegments.indexOf('collections');
      if (collectionsIndex != -1 &&
          collectionsIndex + 1 < pathSegments.length) {
        final String handle = pathSegments[collectionsIndex + 1];
        print('Extracted collection handle from URL: $handle');

        final response = await http.get(
          Uri.parse('https://new-test.megascale.co.in/api/p1/collections'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final List<dynamic> smartCollections =
              data['smart_collections'] ?? [];
          final List<dynamic> customCollections =
              data['custom_collections'] ?? [];
          final List<dynamic> allCollections = [
            ...smartCollections,
            ...customCollections,
          ];

          final collection = allCollections.firstWhere(
                (c) => c != null && c['handle']?.toString() == handle,
            orElse: () => null,
          );

          if (collection != null) {
            final String title = collection['title'] ?? 'Collection';
            final String collectionId = collection['id'] ?? '';

            print('Navigating to collection: $title (ID: $collectionId)');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CategoryListScreen(),
                // Categorieslist(title: title, collectionId: ""),
              ),
            );
          } else {
            print('Collection with handle $handle not found in API.');
          }
        } else {
          print('Failed to load collections: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error handling link navigation: $e');
    }
  }

  Future<void> registerGuestData() async {
    try {
      String deviceId = 'unknown_device';
      final deviceInfo = DeviceInfoPlugin();
      try {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_device';
        }
      } catch (e) {
        print('Error getting device info: $e');
      }

      final payload = {
        'deviceId': deviceId,
        'firstName': 'Guest',
        'city': 'Mumbai',
      };

      print('===== Register Guest Data Payload =====');
      print(jsonEncode(payload));
      print('=======================================');

      final url = Uri.parse(
        'https://new-test.megascale.co.in/api/p1/guest-data',
      );

      print('API URL: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('Register Guest Data response: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('Error registering guest data: $e');
    }
  }

  Future<void> updateGuestFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('fcmToken');

      if (token == null || token.isEmpty) {
        token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await prefs.setString('fcmToken', token);
        }
      }

      if (token == null || token.isEmpty) {
        print('FCM token not available for guest');
        return;
      }

      String deviceId = 'unknown_device';
      final deviceInfo = DeviceInfoPlugin();
      try {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_device';
        }
      } catch (e) {
        print('Error getting device info: $e');
      }

      final payload = {'token': token};

      print('===== Guest FCM Update Payload =====');
      print(jsonEncode(payload));
      print('====================================');

      final url = Uri.parse(
        'https://new-test.megascale.co.in/api/p1/guest-data/$deviceId/fcm',
      );

      print('API URL: $url');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('Guest FCM update response: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('Error updating guest FCM token: $e');
    }
  }

  Future<void> updateCustomerFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? mobileNumber = prefs.getString('mobileNumber');

      if (mobileNumber == null || mobileNumber.isEmpty) {
        print('Mobile number not available for FCM update');
        return;
      }

      String? token = prefs.getString('fcmToken');

      if (token == null || token.isEmpty) {
        token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await prefs.setString('fcmToken', token);
        }
      }

      if (token == null || token.isEmpty) {
        print('FCM token not available for customer');
        return;
      }

      final payload = {'token': token};

      print('===== Customer FCM Update Payload =====');
      print(jsonEncode(payload));
      print('=======================================');

      final url = Uri.parse(
        'https://new-test.megascale.co.in/api/p1/profile/$mobileNumber/fcm',
      );

      print('API URL: $url');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('Customer FCM update response: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('Error updating customer FCM token: $e');
    }
  }

  Future<void> subscribeToBackInStock({
    required String productId,
    required String productTitle,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? mobileNumber = prefs.getString('mobileNumber');

      if (mobileNumber == null || mobileNumber.isEmpty) {
        throw Exception('Please login to subscribe for notifications');
      }

      final payload = {
        'mobileNumber': mobileNumber,
        'productId': productId,
        'productTitle': productTitle,
      };

      print('===== Back In Stock Subscription Payload =====');
      print(jsonEncode(payload));
      print('=============================================');

      final url = Uri.parse(
        'https://new-test.megascale.co.in/api/p1/stock/subscribe',
      );

      print('API URL: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('Back In Stock response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to subscribe');
      }
    } catch (e) {
      print('Error subscribing to back-in-stock: $e');
      rethrow;
    }
  }
}
