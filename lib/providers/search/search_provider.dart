import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/search/search_response_model.dart';
import '../../services/search/search_api_service.dart';

class SearchProvider with ChangeNotifier {
  final SearchApiService _apiService = SearchApiService();

  List<SearchProduct> _products = [];
  List<SearchCollection> _collections = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _query = '';
  Timer? _debounce;

  List<SearchProduct> get products => _products;
  List<SearchCollection> get collections => _collections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get query => _query;

  void setQuery(String query) {
    _query = query;
    _errorMessage = null;
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _products = [];
      _collections = [];
      _isLoading = false;
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), _search);
    notifyListeners();
  }

  Future<void> _search() async {
    _isLoading = true;
    notifyListeners();
    try {
      final raw = await _apiService.search(_query);
      // Parse products list
      final List<dynamic> productsJson = raw['products'] as List? ?? [];
      _products = productsJson
          .map((e) => SearchProduct.fromJson(e as Map<String, dynamic>))
          .toList();
      // Parse collections list
      final List<dynamic> collectionsJson = raw['collections'] as List? ?? [];
      _collections = collectionsJson
          .map(
            (e) => SearchCollection(
              id: e['id']?.toString() ?? '',
              title: e['title']?.toString() ?? '',
              imageUrl: e['image'] is Map
                  ? e['image']['url']?.toString()
                  : e['image']?.toString(),
            ),
          )
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
      _products = [];
      _collections = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _debounce?.cancel();
    _query = '';
    _products = [];
    _collections = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class SearchCollection {
  final String id;
  final String title;
  final String? imageUrl;

  SearchCollection({required this.id, required this.title, this.imageUrl});

  factory SearchCollection.fromJson(Map<String, dynamic> json) =>
      SearchCollection(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        imageUrl: json['image']?.toString(),
      );
}
