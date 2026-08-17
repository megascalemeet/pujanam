import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
      ),
      body: const Center(
        child: Text('Cart Screen Stub'),
      ),
    );
  }
}
