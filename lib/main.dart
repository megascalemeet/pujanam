import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pujanam/pages/splash/splash_screen.dart';
import 'package:pujanam/providers/auth/auth_provider.dart';
import 'package:pujanam/providers/category/category_provider.dart';
import 'package:pujanam/providers/customer/customer_provider.dart';

import 'pages/home/home_screen.dart';
import 'pages/orders/orders_screen.dart';
import 'pages/profile/profile_screen.dart';
import 'pages/wishlist/wishlist_screen.dart';
import 'providers/product/product_provider.dart';
import 'widgets/bottom navigation/app_bottom_navigation.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
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
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  DateTime? _lastPressed;

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
