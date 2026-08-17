import 'package:flutter/material.dart';
import '../../models/product/product_response_model.dart';
import '../../services/product/product_api_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductApiService _apiService = ProductApiService();

  List<ProductModel> _products = [];
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  int get currentPage => _currentPage;
  bool get hasNextPage => _hasNextPage;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  Future<void> loadInitialProducts() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _products = [];
    notifyListeners();

    try {
      final response = await _apiService.fetchProducts(page: _currentPage, limit: 10);
      _products = response.data;
      _hasNextPage = response.pagination.hasNextPage;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts() async {
    if (_isLoading || _isLoadingMore || !_hasNextPage) return;
    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _apiService.fetchProducts(page: nextPage, limit: 10);
      _products.addAll(response.data);
      _currentPage = nextPage;
      _hasNextPage = response.pagination.hasNextPage;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshProducts() async {
    await loadInitialProducts();
  }
}
