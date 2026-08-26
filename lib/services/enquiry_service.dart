import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class EnquiryService {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const String _url = '$_baseUrl/shop/enquiries';

  Future<bool> submitEnquiry({
    required String firstName,
    required String lastName,
    required String mobile,
    required String email,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
          'X-Shopfront-Token': ApiConstants.shopfrontToken,
        },
        body: jsonEncode({
          "first_name": firstName,
          "last_name": lastName,
          "mobile": mobile,
          "email": email,
          "message": message,
        }),
      );
      print('================ ENQUIRY RESPONSE ===============');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('==================================================');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // Log error or handle as needed
        print(
          'Enquiry submission failed: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Enquiry submission error: $e');
      return false;
    }
  }
}
