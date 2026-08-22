import 'package:flutter/material.dart';
import '../../models/category/category_product_response_model.dart';
import '../../models/category/category_response_model.dart';
import '../../services/category/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoriesApiService _apiService = CategoriesApiService();

  // Categories (Collections) State
  List<CategoryModel> _categories = [];
  bool _isCategoriesLoading = false;
  String? _categoriesError;

  // Products State (for the current selected category)
  List<CategoryProductModel> _products = [];
  bool _isProductsLoading = false;
  String? _productsError;

  // Perfume Products State (separate to avoid conflict with selected category)
  List<CategoryProductModel> _perfumeProducts = [];
  // Reuse loading and error flags for perfume fetch (can share)

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isCategoriesLoading => _isCategoriesLoading;
  String? get categoriesError => _categoriesError;

  List<CategoryProductModel> get products => _products;
  bool get isProductsLoading => _isProductsLoading;
  String? get productsError => _productsError;

  List<CategoryProductModel> get perfumeProducts => _perfumeProducts;

  // Existing method to load categories
  Future<void> loadCategories() async {
    _isCategoriesLoading = true;
    _categoriesError = null;
    notifyListeners();

    try {
      _categories = await _apiService.fetchCollections();
    } catch (e) {
      _categoriesError = e.toString();
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
  }

  // Existing method to fetch products for a specific category handle
  Future<void> fetchProducts(String handle) async {
    _isProductsLoading = true;
    _productsError = null;
    notifyListeners();

    try {
      _products = await _apiService.fetchProductsByCategory(handle);
    } catch (e) {
      _productsError = e.toString();
      _products = [];
    } finally {
      _isProductsLoading = false;
      notifyListeners();
    }
  }

  // New method to fetch perfume products (limited to 4)
  Future<void> fetchPerfumeProducts() async {
    _isProductsLoading = true;
    _productsError = null;
    notifyListeners();

    try {
      final products = await _apiService.fetchProductsByCategory('perfume');
      _perfumeProducts = products.take(4).toList();
      debugPrint('[HOME] Fetched ${_perfumeProducts.length} perfume products');
    } catch (e) {
      _productsError = e.toString();
      _perfumeProducts = [];
    } finally {
      _isProductsLoading = false;
      notifyListeners();
    }
  }

  void clearProducts() {
    _products = [];
    _productsError = null;
    notifyListeners();
  }
}
