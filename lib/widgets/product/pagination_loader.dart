import 'package:flutter/material.dart';

class PaginationLoader extends StatelessWidget {
  const PaginationLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: CircularProgressIndicator(
          color: Color.fromRGBO(111, 10, 15, 1),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
