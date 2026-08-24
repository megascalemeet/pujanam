import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class WishlistApiService {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const String _shopfrontToken = ApiConstants.shopfrontToken;

  // GET Wishlist
  Future<http.Response> getWishlist(String customerToken) async {
    final url = Uri.parse('$_baseUrl/shop/wishlist');
    debugPrint('========== GET WISHLIST ==========');
    debugPrint('URL: $url');

    final response = await http.get(
      url,
      headers: {
        'X-Shopfront-Token': _shopfrontToken,
        'Authorization': 'Bearer $customerToken',
      },
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('shoptoken: $_shopfrontToken');
    debugPrint('Authorization: $customerToken');
    debugPrint('Response: ${response.body}');
    debugPrint('==================================');
    return response;
  }

  // TOGGLE Wishlist (Add/Remove)
  Future<http.Response> toggleWishlist(String customerToken, int productId, {int? variantId}) async {
    final url = Uri.parse('$_baseUrl/shop/wishlist/toggle');
    debugPrint('========== TOGGLE WISHLIST ==========');
    debugPrint('URL: $url');
    debugPrint('Product ID: $productId');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': _shopfrontToken,
        'Authorization': 'Bearer $customerToken',
      },
      body: json.encode({
        'product_id': productId,
        'variant_id': variantId,
      }),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('====================================');
    return response;
  }

  // DELETE Wishlist entry
  Future<http.Response> deleteWishlistEntry(String customerToken, int wishlistEntryId) async {
    final url = Uri.parse('$_baseUrl/shop/wishlist/$wishlistEntryId');
    debugPrint('========== DELETE WISHLIST ENTRY ==========');
    debugPrint('URL: $url');

    final response = await http.delete(
      url,
      headers: {
        'X-Shopfront-Token': _shopfrontToken,
        'Authorization': 'Bearer $customerToken',
      },
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('===========================================');
    return response;
  }
}
