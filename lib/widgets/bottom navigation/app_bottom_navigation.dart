import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: NavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        indicatorColor: const Color.fromRGBO(111, 10, 15, 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded,
                color: Color.fromRGBO(111, 10, 15, 1)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline_rounded),
            selectedIcon: Icon(Icons.favorite_rounded,
                color: Color.fromRGBO(111, 10, 15, 1)),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag_rounded,
                color: Color.fromRGBO(111, 10, 15, 1)),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded,
                color: Color.fromRGBO(111, 10, 15, 1)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
