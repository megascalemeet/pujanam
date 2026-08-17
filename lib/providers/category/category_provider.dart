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

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isCategoriesLoading => _isCategoriesLoading;
  String? get categoriesError => _categoriesError;

  List<CategoryProductModel> get products => _products;
  bool get isProductsLoading => _isProductsLoading;
  String? get productsError => _productsError;

  // Fetch all collections
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

  // Fetch products for a specific category handle
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

  void clearProducts() {
    _products = [];
    _productsError = null;
    notifyListeners();
  }
}
