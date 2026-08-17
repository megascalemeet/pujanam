import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/auth/login.dart';
import '../pages/cart/cart.dart';

class CartService {
  static const String baseUrl = 'https://new-test.megascale.co.in/api/p1';

  static Future<void> addToCart(
    dynamic product,
    BuildContext context, {
    String? selectedWeight,
    String? selectedPrice,
    String? variantId,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? customerId = prefs.getString('customer_id');
      
      String productId;
      String productTitle;
      if (product is Map) {
        productId = product['id'].toString();
        productTitle = product['title']?.toString() ?? 'Item';
      } else {
        productId = product.id.toString();
        productTitle = product.title;
      }

      if (customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to add items to cart'),
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        });
        return;
      }

      final cartResponse = await http.get(
        Uri.parse('$baseUrl/cart?customer_id=$customerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (cartResponse.statusCode == 200) {
        final cartData = json.decode(cartResponse.body);
        int quantity = 1;

        if (cartData['cart'] != null && (cartData['cart'] as List).isNotEmpty) {
          for (var item in cartData['cart']) {
            if (item['product_id'].toString() == productId && item['weight'] == selectedWeight) {
              quantity = (item['quantity'] as int) + 1;
              break;
            }
          }
        }

        String? imageSrc;
        if (product is Map) {
          var images = product['images'] ?? product['media'];
          if (images is List && images.isNotEmpty) {
            imageSrc = images[0] is Map ? (images[0]['url'] ?? images[0]['previewSrc'] ?? images[0]['src'])?.toString() : images[0].toString();
          }
        } else {
          if (product.images.isNotEmpty) {
            imageSrc = product.images[0].url;
          }
        }

        final response = await http.post(
          Uri.parse('$baseUrl/addtocart'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'customer_id': customerId,
            'product_id': productId,
            'quantity': quantity,
            'weight': selectedWeight,
            'price': selectedPrice,
            'variant_id': variantId,
            'image': imageSrc,
            'title': productTitle,
          }),
        );

        if (response.statusCode == 200) {
          showCustomNotification(context, productTitle, imageSrc);
        } else {
          throw Exception('Failed to add to cart: ${response.body}');
        }
      } else {
        throw Exception('Failed to fetch cart: ${cartResponse.body}');
      }
    } catch (e) {
      showCustomErrorNotification(context, e.toString());
    }
  }

  static void showCustomNotification(BuildContext context, String title, String? imageUrl) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SizedBox(
          height: 60,
          child: Row(
            children: [
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Added to Cart',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color.fromRGBO(111, 10, 15, 1),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  static void showCustomErrorNotification(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Error: ${error.replaceAll('Exception:', '')}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static Future<Map<String, dynamic>> getCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerId = prefs.getString('customer_id');

    if (customerId == null) {
      throw Exception('User not logged in');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/cart?customer_id=$customerId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  static Future<void> updateQuantity(String itemId, int newQuantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerId = prefs.getString('customer_id');

    if (customerId == null) {
      throw Exception('User not logged in');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/editcart'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'customer_id': customerId,
        'product_id': itemId,
        'quantity': newQuantity
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update quantity');
    }
  }
}
