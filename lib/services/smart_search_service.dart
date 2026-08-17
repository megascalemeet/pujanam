import 'dart:convert';
import 'package:http/http.dart' as http;

class SmartSearchService {
  static const String baseUrl = 'https://new-test.megascale.co.in/api/p1';

  Future<Map<String, dynamic>> searchProducts(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) {
      return {
        'products': [],
        'collections': [],
        'searchQuery': '',
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?search=${Uri.encodeComponent(query)}&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'products': data['products'] ?? [],
          'collections': data['collections'] ?? [],
          'searchQuery': data['searchQuery'] ?? query,
        };
      } else {
        return {
          'products': [],
          'collections': [],
          'searchQuery': query,
        };
      }
    } catch (e) {
      return {
        'products': [],
        'collections': [],
        'searchQuery': query,
      };
    }
  }
}
