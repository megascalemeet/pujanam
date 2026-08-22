import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../models/checkout/coupon_model.dart';

class CheckoutApiService {
  static final String _baseUrl = ApiConstants.checkoutBaseUrl;
  static const String _merchantId = ApiConstants.checkoutMerchantId;
  static const String _apiKey = ApiConstants.checkoutApiKey;

  Future<CouponResponse> fetchCoupons() async {
    final url = '$_baseUrl/checkout/coupons?merchantId=$_merchantId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return CouponResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load coupons (${response.statusCode})');
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addAddressToCheckout(
    String sessionToken,
    Map<String, dynamic> addressData,
  ) async {
    final url = '$_baseUrl/checkout/session/$sessionToken/address';
    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
      body: json.encode(addressData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to add address to checkout: ${response.statusCode}',
      );
    }
  }

  /// Saves the address into the customer portal profile
  Future<Map<String, dynamic>> saveAddressToCustomerPortal(
    String platformToken,
    Map<String, dynamic> portalAddressData,
  ) async {
    final url = '$_baseUrl/v1/customer-portal/addresses';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'x-store-origin': ApiConstants.storeOrigin,
        'Authorization': 'Bearer $platformToken',
      },
      body: json.encode(portalAddressData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to save address to customer portal: ${response.statusCode}',
      );
    }
  }

  /// Apply a coupon code to an active checkout session.
  Future<Map<String, dynamic>> applyCoupon(
    String sessionToken,
    String couponCode,
  ) async {
    final url = '$_baseUrl/checkout/session/$sessionToken/discount';

    debugPrint('========== APPLY COUPON API ==========');
    debugPrint('URL: $url');
    debugPrint('Method: POST');
    debugPrint('Headers:');
    debugPrint(
      jsonEncode({'Content-Type': 'application/json', 'x-api-key': _apiKey}),
    );
    debugPrint('Request Body:');
    debugPrint(jsonEncode({'code': couponCode}));

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
      body: json.encode({'code': couponCode}),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response Body:');
    debugPrint(response.body);
    debugPrint('======================================');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      try {
        final body = json.decode(response.body);
        final msg = body['message'] ?? body['error'];
        if (msg != null) throw Exception(msg.toString());
      } catch (_) {}

      throw Exception('Failed to apply coupon');
    }
  }

  /// Remove / clear the applied coupon from an active checkout session.
  Future<Map<String, dynamic>> removeCoupon(
    String sessionToken,
    String couponCode,
  ) async {
    final url = '$_baseUrl/checkout/session/$sessionToken/discount/$couponCode';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      // 204 No Content is a valid success for DELETE
      if (response.body.isEmpty) return {'success': true};
      return json.decode(response.body);
    } else {
      throw Exception('Failed to remove coupon (${response.statusCode})');
    }
  }
}
