import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../models/auth/auth_models.dart';

class AuthApiService {
  static const String _baseUrl = ApiConstants.baseUrl;
  // Shopfront token for authentication
  static const String _shopfrontToken = ApiConstants.shopfrontToken;

  Future<SendOtpResponse> sendOtp(String phone) async {
    final url = '$_baseUrl/shop/auth/send-otp';

    debugPrint('========== SEND OTP ==========');
    debugPrint('URL: $url');
    debugPrint('Method: POST');
    debugPrint('Phone: $phone');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': _shopfrontToken,
      },
      body: json.encode({'phone': phone}),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('==============================');

    return SendOtpResponse.fromJson(json.decode(response.body));
  }

  Future<VerifyOtpResponse> verifyOtp(String phone, String otp) async {
    final url = '$_baseUrl/shop/auth/verify-otp';

    debugPrint('========== VERIFY OTP ==========');
    debugPrint('URL: $url');
    debugPrint('Method: POST');
    debugPrint('Phone: $phone');
    debugPrint('OTP: $otp');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': _shopfrontToken,
      },
      body: json.encode({'phone': phone, 'otp': otp}),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('================================');

    return VerifyOtpResponse.fromJson(json.decode(response.body));
  }

  Future<void> registerGuestFcmToken({
    required String fcmToken,
    required String guestId,
    required String deviceType,
    required String deviceModel,
    required String appVersion,
  }) async {
    final url = '$_baseUrl/shop/guest/fcm-token';

    debugPrint('========== REGISTER GUEST FCM TOKEN ==========');
    debugPrint('URL: $url');
    final body = {
      'fcm_token': fcmToken,
      'guest_id': guestId,
      'device_type': deviceType,
      'device_model': deviceModel,
      'app_version': appVersion,
    };
    debugPrint('Body: ${json.encode(body)}');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': _shopfrontToken,
      },
      body: json.encode(body),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('==============================================');
  }

  Future<void> registerCustomerFcmToken({
    required String fcmToken,
    required String deviceType,
    required String token,
    String? browser,
    String? os,
  }) async {
    final url = '$_baseUrl/shop/customer/fcm-token';

    debugPrint('========== REGISTER CUSTOMER FCM TOKEN ==========');
    debugPrint('URL: $url');
    final body = {
      'fcm_token': fcmToken,
      'device_type': deviceType,
      if (browser != null) 'browser': browser,
      if (os != null) 'os': os,
    };
    debugPrint('Body: ${json.encode(body)}');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': _shopfrontToken,
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('================================================');
  }

  Future<void> deleteCustomerFcmToken({
    required String fcmToken,
    required String token,
  }) async {
    final url = '$_baseUrl/shop/customer/fcm-token';

    debugPrint('========== DELETE CUSTOMER FCM TOKEN ==========');
    debugPrint('URL: $url');
    final body = {'fcm_token': fcmToken};
    debugPrint('Body: ${json.encode(body)}');

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': _shopfrontToken,
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('================================================');
  }
}
