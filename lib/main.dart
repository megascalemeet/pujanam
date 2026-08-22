import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pujanam/pages/splash/splash_screen.dart';
import 'package:pujanam/providers/auth/auth_provider.dart';
import 'package:pujanam/providers/cart/cart_provider.dart';
import 'package:pujanam/providers/category/category_provider.dart';
import 'package:pujanam/providers/checkout/checkout_provider.dart';
import 'package:pujanam/providers/customer/customer_provider.dart';
import 'package:pujanam/providers/orders/order_provider.dart';
import 'package:pujanam/providers/payment_provider.dart';
import 'package:pujanam/providers/search/search_provider.dart';
import 'package:pujanam/services/notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home/home_screen.dart';
import 'pages/orders/orders_screen.dart';
import 'pages/profile/profile_screen.dart';
import 'pages/wishlist/wishlist_screen.dart';
import 'providers/product/product_provider.dart';
import 'widgets/bottom navigation/app_bottom_navigation.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message received: ${message.notification?.title}");
  print("Background message data: ${message.data}");
  print("Background notification payload: ${message.notification?.toMap()}");
}

Future<void> requestNotificationPermission() async {
  var status = await Permission.notification.status;
  if (status.isDenied) {
    status = await Permission.notification.request();
  }
  if (status.isPermanentlyDenied) {
    await openAppSettings();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final notificationServices = NotificationServices();
  await notificationServices.initialize();

  // Save FCM Token
  String? token = await FirebaseMessaging.instance.getToken();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('fcmToken', token ?? '');
  print("FCM Token : $token");

  await requestNotificationPermission();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()..loadCart()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: const PujnamApp(),
    ),
  );
}

class PujnamApp extends StatelessWidget {
  const PujnamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pujnam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(111, 10, 15, 1),
          primary: const Color.fromRGBO(111, 10, 15, 1),
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      //const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;
  DateTime? _lastPressed;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    WishlistScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false;
        }
        final now = DateTime.now();
        if (_lastPressed == null ||
            now.difference(_lastPressed!) > const Duration(seconds: 2)) {
          _lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
              backgroundColor: Color.fromRGBO(111, 10, 15, 1),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: AppBottomNavigation(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
        ),
      ),
    );
  }
}
