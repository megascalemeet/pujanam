import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../models/category/category_product_response_model.dart';
import '../../models/category/category_response_model.dart';

class CategoriesApiService {
  Future<List<CategoryModel>> fetchCollections() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/shop/collections?limit=50'),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': ApiConstants.shopfrontToken,
        'x-store-id': ApiConstants.storeId,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List)
            .map((json) => CategoryModel.fromJson(json))
            .where((category) {
              bool hasProducts = category.productCount != '0';
              bool isPercentage = category.title.contains('%');
              // Filters: product_count != "0", is_display == true, title without "%"
              return category.isDisplay && hasProducts && !isPercentage;
            })
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<CategoryProductModel>> fetchProductsByCategory(
    String handle,
  ) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/shop/collections/$handle'),
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': ApiConstants.shopfrontToken,
        'x-store-id': ApiConstants.storeId,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true &&
          data['data'] != null &&
          data['data']['products'] is List) {
        return (data['data']['products'] as List)
            .map((json) => CategoryProductModel.fromJson(json))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to load products for category: $handle');
    }
  }
}
