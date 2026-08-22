import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../models/orders/order_models.dart';

class OrderApiService {
  static const String _baseUrl = ApiConstants.checkoutBaseUrl;
  static const String _apiKey = ApiConstants.checkoutApiKey;
  static const String _storeOrigin = ApiConstants.storeOrigin;


  Future<MergedOrdersResponse> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final platformToken = prefs.getString('platformToken') ?? '';

    final url = '$_baseUrl/v1/customer-portal/orders?page=1&limit=20';

    debugPrint('========== FETCH ORDERS ==========');
    debugPrint('URL: $url');
    debugPrint('Platform Token: $platformToken');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-api-key': _apiKey,
        'x-store-origin': _storeOrigin,
        'Authorization': 'Bearer $platformToken',
      },
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('==================================');

    return MergedOrdersResponse.fromJson(json.decode(response.body));
  }

  Future<AddToCartResponse> addToCart(AddToCartRequest request) async {
    final url = '$_baseUrl/checkout/session';

    debugPrint('========== ADD TO CART (CHECKOUT SESSION) ==========');
    debugPrint('URL: $url');
    debugPrint('Payload: ${json.encode(request.toJson())}');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
      },
      body: json.encode(request.toJson()),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('====================================================');

    return AddToCartResponse.fromJson(json.decode(response.body));
  }
}
