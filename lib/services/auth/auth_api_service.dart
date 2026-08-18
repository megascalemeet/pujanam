import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/auth/auth_models.dart';

class AuthApiService {
  static const String _baseUrl = 'https://api-checkout.store.nilkanthdham.in/api';
  static const String _merchantId = 'c63ffaef-8532-4906-af10-abb6ba1d5800';

  Future<SendOtpResponse> sendOtp(String phone) async {
    final url = '$_baseUrl/checkout/auth/phone/send-otp';

    debugPrint('========== SEND OTP ==========');
    debugPrint('URL: $url');
    debugPrint('Method: POST');
    debugPrint('Phone: $phone');
    debugPrint('Merchant ID: $_merchantId');
    debugPrint('Channel: whatsapp');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'phone': phone,
        'merchantId': _merchantId,
        'channel': 'whatsapp',
      }),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('==============================');

    return SendOtpResponse.fromJson(json.decode(response.body));
  }

  Future<VerifyOtpResponse> verifyOtp(String phone, String otp) async {
    final url = '$_baseUrl/checkout/auth/phone/verify-otp';

    debugPrint('========== VERIFY OTP ==========');
    debugPrint('URL: $url');
    debugPrint('Method: POST');
    debugPrint('Phone: $phone');
    debugPrint('OTP: $otp');
    debugPrint('Merchant ID: $_merchantId');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'phone': phone,
        'otp': otp,
        'merchantId': _merchantId,
      }),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('================================');

    return VerifyOtpResponse.fromJson(json.decode(response.body));
  }
}
