// Address service for profile management
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../models/customer/customer_address.dart';

class AddressApiService {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const String _shopfrontToken = ApiConstants.shopfrontToken;

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<List<CustomerAddress>> getAddresses() async {
    final token = await _getAuthToken();
    final url = '$_baseUrl/shop/customer/addresses';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': _shopfrontToken,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final dynamic decoded = _decode(response);
      List<dynamic> jsonList = [];

      if (decoded is List) {
        jsonList = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        jsonList = decoded['data'];
      }

      return jsonList
          .map((e) => CustomerAddress.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch addresses: ${response.body}');
    }
  }

  Future<CustomerAddress> createAddress(CustomerAddress address) async {
    final token = await _getAuthToken();
    final url = '$_baseUrl/shop/customer/addresses';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': _shopfrontToken,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(address.toJson()),
    );
    debugPrint(
      'CREATE ADDRESS RESPONSE: ${response.statusCode} - ${response.body}',
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CustomerAddress.fromJson(
        _decode(response) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create address: ${response.body}');
    }
  }

  Future<CustomerAddress> updateAddress(int id, CustomerAddress address) async {
    final token = await _getAuthToken();
    final url = '$_baseUrl/shop/customer/addresses/$id';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': _shopfrontToken,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(address.toJson()),
    );
    debugPrint(
      'UPDATE ADDRESS RESPONSE (MEGA): ${response.statusCode} - ${response.body}',
    );
    if (response.statusCode == 200) {
      return CustomerAddress.fromJson(
        _decode(response) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to update address: ${response.body}');
    }
  }

  Future<void> setDefaultAddress(int id) async {
    final token = await _getAuthToken();
    final url = '$_baseUrl/shop/customer/addresses/$id/default';
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': _shopfrontToken,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to set default address: ${response.body}');
    }
  }

  dynamic _decode(http.Response response) {
    try {
      return json.decode(response.body);
    } catch (e) {
      debugPrint('DECODE ERROR (AddressApiService): $e');
      debugPrint('RAW BODY: ${response.body}');
      throw Exception('Invalid response format from server.');
    }
  }
}
