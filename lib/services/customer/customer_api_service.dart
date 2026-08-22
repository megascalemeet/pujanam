import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/customer/customer_address.dart';
import '../../models/customer/customer_profile.dart';

class CustomerApiService {
  static const _baseUrl =
      'https://api-checkout.store.nilkanthdham.in/api/v1/customer-portal';
  static const _apiKey = 'mk_public_e6b43102';
  //'mk_public_your_public_key';
  static const _storeOrigin = 'store.nilkanthdham.in';

  Future<Map<String, String>> _headers({bool json = false}) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('platformToken');
    if (token == null || token.isEmpty) {
      throw Exception('Please log in again to continue.');
    }
    return {
      'x-api-key': _apiKey,
      'x-store-origin': _storeOrigin,
      'Authorization': 'Bearer $token',
      if (json) 'Content-Type': 'application/json',
    };
  }

  Future<CustomerProfile> getProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/profile'),
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
      'firstName': firstName,
      'lastName': lastName,
      if (email?.isNotEmpty == true) 'email': email!,
    };
    final response = await http.patch(
      Uri.parse('$_baseUrl/profile'),
      headers: await _headers(json: true),
      body: jsonEncode(changes),
    );
    return CustomerProfile.fromJson(_decode(response));
  }

  Future<List<CustomerAddress>> getAddresses() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/addresses'),
      headers: await _headers(),
    );
    final body = _decode(response);
    final data = body['data'];
    final addresses = data is List ? data : <dynamic>[];
    return addresses
        .whereType<Map<String, dynamic>>()
        .map(CustomerAddress.fromJson)
        .toList();
  }

  Future<CustomerAddress> addAddress(CustomerAddress address) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/addresses'),
      headers: await _headers(json: true),
      body: jsonEncode(address.toJson()),
    );
    return CustomerAddress.fromJson(_decode(response));
  }

  Future<CustomerAddress> updateAddress(
    String addressId,
    Map<String, dynamic> changes,
  ) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/addresses/$addressId'),
      headers: await _headers(json: true),
      body: jsonEncode(changes),
    );
    return CustomerAddress.fromJson(_decode(response));
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Request failed (${response.statusCode}).',
      );
    }
    return body;
  }
}
