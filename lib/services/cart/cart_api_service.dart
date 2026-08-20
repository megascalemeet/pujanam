import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/cart/cart_models.dart';

class CartApiService {
  static const String _baseUrl = 'https://api-checkout.store.nilkanthdham.in/api';
  static const String _apiKey = 'mk_public_e6b43102';

  Future<CheckoutSessionResponse> createCheckoutSession(List<CartItem> items) async {
    final url = '$_baseUrl/checkout/session';

    final requestBody = {
      'currency': 'INR',
      'cartItems': items.map((item) => {
        'productId': item.productId,
        'variantId': item.variantId,
        'sku': item.sku,
        'title': item.title,
        'name': item.title,
        'variantTitle': item.weight,
        'imageUrl': item.imageUrl,
        'price': (item.price * 100).toInt(),
        'compareAtPrice': ((item.compareAtPrice > 0 ? item.compareAtPrice : item.price) * 100).toInt(),
        'quantity': item.quantity,
        'weight': int.tryParse(item.weight.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        'weightUnit': 'g',
      }).toList(),
    };

    debugPrint('========== CREATE CHECKOUT SESSION ==========');
    debugPrint('URL: $url');
    debugPrint('Payload: ${json.encode(requestBody)}');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
      },
      body: json.encode(requestBody),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('=============================================');

    return CheckoutSessionResponse.fromJson(json.decode(response.body));
  }

  Future<CheckoutSessionResponse> getCheckoutState(String sessionToken) async {
    final url = '$_baseUrl/checkout/session/$sessionToken';

    debugPrint('========== FETCH CHECKOUT STATE ==========');
    debugPrint('URL: $url');

    final response = await http.get(
      Uri.parse(url),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('==========================================');

    return CheckoutSessionResponse.fromJson(json.decode(response.body));
  }

  Future<CheckoutSessionResponse> updateCartItems(String sessionToken, List<CartItem> items) async {
    final url = '$_baseUrl/checkout/session/$sessionToken/items';

    final requestBody = {
      'currency': 'INR',
      'cartItems': items.map((item) => {
        'productId': item.productId,
        'variantId': item.variantId,
        'sku': item.sku,
        'title': item.title,
        'name': item.title,
        'variantTitle': item.weight,
        'imageUrl': item.imageUrl,
        'price': (item.price * 100).toInt(),
        'compareAtPrice': ((item.compareAtPrice > 0 ? item.compareAtPrice : item.price) * 100).toInt(),
        'quantity': item.quantity,
        'weight': int.tryParse(item.weight.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        'weightUnit': 'g',
      }).toList(),
    };

    debugPrint('========== UPDATE CHECKOUT SESSION ITEMS ==========');
    debugPrint('URL: $url');
    debugPrint('Payload: ${json.encode(requestBody)}');

    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
      },
      body: json.encode(requestBody),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('====================================================');

    return CheckoutSessionResponse.fromJson(json.decode(response.body));
  }
}
