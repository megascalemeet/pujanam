import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationServices {
  static final NotificationServices _instance =
      NotificationServices._internal();
  factory NotificationServices() => _instance;
  NotificationServices._internal();

  Future<void> subscribeToBackInStock({
    required String productId,
    required String productTitle,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? mobileNumber = prefs.getString('mobileNumber');

      if (mobileNumber == null || mobileNumber.isEmpty) {
        throw Exception('Please login to subscribe for notifications');
      }

      final payload = {
        'mobileNumber': mobileNumber,
        'productId': productId,
        'productTitle': productTitle,
      };

      final response = await http.post(
        Uri.parse('https://new-test.megascale.co.in/api/p1/stock/subscribe'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to subscribe');
      }
    } catch (e) {
      rethrow;
    }
  }
}
