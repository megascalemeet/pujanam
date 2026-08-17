import 'package:flutter/material.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Your Wishlist is Empty',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
