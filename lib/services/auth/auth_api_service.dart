import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class AuthApiService {
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/shop/send-otp'),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': ApiConstants.shopfrontToken,
      },
      body: json.encode({'phone': phone}),
    );

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String otp, {
    String? cartToken,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/verify-otp'),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': ApiConstants.shopfrontToken,
      },
      body: json.encode({
        'phone': phone,
        'otp': otp,
        if (cartToken != null) 'cart_token': cartToken,
      }),
    );

    return json.decode(response.body);
  }
}
