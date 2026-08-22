import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../models/customer/customer_address.dart';
import '../../models/customer/customer_profile.dart';

class CustomerApiService {
  static const _baseUrl = ApiConstants.baseUrl;
  static const _shopfrontToken = ApiConstants.shopfrontToken;

  Future<Map<String, String>> _headers({bool json = false}) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('accessToken');
    if (token == null || token.isEmpty) {
      throw Exception('Please log in again to continue.');
    }
    return {
      'X-Shopfront-Token': _shopfrontToken,
      'Authorization': 'Bearer $token',
      if (json) 'Content-Type': 'application/json',
    };
  }

  Future<CustomerProfile> getProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/shop/customer/me'),
      headers: await _headers(),
    );
    return CustomerProfile.fromJson(_decode(response));
  }

  Future<CustomerProfile> updateProfile({
    required String firstName,
    required String lastName,
    String? email,
    String? phoneNumber,
  }) async {
    final changes = <String, String>{
      'first_name': firstName,
      'last_name': lastName,
      if (email?.isNotEmpty == true) 'email': email!,
      if (phoneNumber?.isNotEmpty == true) 'phone': phoneNumber!,
    };
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/shop/customer/me'),
        headers: await _headers(json: true),
        body: jsonEncode(changes),
      );
      debugPrint(
        'UPDATE PROFILE RESPONSE: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        return CustomerProfile.fromJson(_decode(response));
      }
    } catch (e) {
      debugPrint('Update profile failed (ignoring): $e');
    }
    // Fallback: return current profile if update fails
    return getProfile();
  }

  Future<List<CustomerAddress>> getAddresses() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/shop/customer/addresses'),
      headers: await _headers(),
    );
    final decoded = _decode(response);
    final data = decoded['data'];
    final addresses = data is List ? data : <dynamic>[];
    return addresses
        .whereType<Map<String, dynamic>>()
        .map(CustomerAddress.fromJson)
        .toList();
  }

  Future<CustomerAddress> addAddress(CustomerAddress address) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/shop/customer/addresses'),
      headers: await _headers(json: true),
      body: jsonEncode(address.toJson()),
    );
    debugPrint(
      'ADD ADDRESS RESPONSE: ${response.statusCode} - ${response.body}',
    );
    return CustomerAddress.fromJson(_decode(response));
  }

  Future<CustomerAddress> updateAddress(
    String addressId,
    CustomerAddress address,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/shop/customer/addresses/$addressId'),
      headers: await _headers(json: true),
      body: jsonEncode(address.toJson()),
    );
    debugPrint(
      'UPDATE ADDRESS RESPONSE: ${response.statusCode} - ${response.body}',
    );
    return CustomerAddress.fromJson(_decode(response));
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          body['message'] ?? 'Request failed (${response.statusCode}).',
        );
      }
      return body;
    } catch (e) {
      debugPrint('DECODE ERROR: $e');
      debugPrint('RAW BODY: ${response.body}');
      if (e is FormatException) {
        throw Exception('Invalid response format from server.');
      }
      rethrow;
    }
  }
}
