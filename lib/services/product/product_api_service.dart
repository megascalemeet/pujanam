import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../models/product/product_detail_response_model.dart';
import '../../models/product/product_response_model.dart';

class ProductApiService {
  Future<ProductResponseModel> fetchProducts({
    required int page,
    required int limit,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/shop/products?page=$page&limit=$limit');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': ApiConstants.shopfrontToken,
        'x-store-id': ApiConstants.storeId,
      },
    );

    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      return ProductResponseModel.fromJson(decodedJson);
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  Future<ProductDetailResponseModel> fetchProductDetail(String handle) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/shop/products/$handle');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Shopfront-Token': ApiConstants.shopfrontToken,
        'x-store-id': ApiConstants.storeId,
      },
    );

    if (response.statusCode == 200) {
      final decodedJson = json.decode(response.body);
      return ProductDetailResponseModel.fromJson(decodedJson);
    } else {
      throw Exception('Failed to load product details: ${response.statusCode}');
    }
  }
}
