import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
      ),
      body: const Center(
        child: Text('Login Screen Stub'),
      ),
    );
  }
}
