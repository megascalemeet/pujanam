import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/wishlist/wishlist_api_service.dart';

class WishlistProvider with ChangeNotifier {
  final WishlistApiService _apiService = WishlistApiService();
  List<dynamic> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch Wishlist Items from API
  Future<void> fetchWishlist() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerToken = prefs.getString('accessToken');

      if (customerToken == null || customerToken.isEmpty) {
        _items = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.getWishlist(customerToken);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['data'] ?? data['wishlist'];
        if (list != null && list is List) {
          _items = list;
          
          // Save list of wishlisted product IDs locally for fast sync check
          final localWishlist = _items
              .map((item) => _normalizeProductId(item['product_id']))
              .where((id) => id != null)
              .map((id) => id.toString())
              .toList();
          await prefs.setStringList('local_wishlist', localWishlist);
        } else {
          _items = [];
          await prefs.setStringList('local_wishlist', []);
        }
      } else {
        _errorMessage = 'Failed to load wishlist';
      }
    } catch (e) {
      _errorMessage = 'Error loading wishlist: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle item in Wishlist
  Future<bool> toggleWishlist(dynamic rawProductId, {int? variantId}) async {
    final productId = _normalizeProductId(rawProductId);
    if (productId == null) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerToken = prefs.getString('accessToken');

      if (customerToken == null || customerToken.isEmpty) {
        _errorMessage = 'Please log in to manage your wishlist';
        notifyListeners();
        return false;
      }

      final response = await _apiService.toggleWishlist(customerToken, productId, variantId: variantId);
      if (response.statusCode == 200) {
        // Refresh local wishlist to fetch the new structure with IDs
        await fetchWishlist();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Failed to update wishlist';
      notifyListeners();
    }
    return false;
  }

  // Remove from wishlist by entry ID (or by product ID fallback)
  Future<bool> removeFromWishlist(dynamic rawProductId) async {
    final productId = _normalizeProductId(rawProductId);
    if (productId == null) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerToken = prefs.getString('accessToken');

      if (customerToken == null || customerToken.isEmpty) {
        return false;
      }

      // Find the wishlist entry ID for this product
      final entry = _items.firstWhere(
        (item) => _normalizeProductId(item['product_id']) == productId,
        orElse: () => null,
      );

      if (entry != null) {
        final entryIdStr = entry['wishlist_item_id'] ?? entry['id'];
        if (entryIdStr != null) {
          final entryId = int.tryParse(entryIdStr.toString());
          if (entryId != null) {
            final response = await _apiService.deleteWishlistEntry(customerToken, entryId);
            if (response.statusCode == 200) {
              await fetchWishlist();
              return true;
            }
          }
        }
      }

      // Fallback: if entry not found or delete fails, try toggling it to remove
      return await toggleWishlist(productId);
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
    }
    return false;
  }

  // Check if a product ID exists in wishlist
  bool isProductWishlisted(dynamic rawProductId) {
    final productId = _normalizeProductId(rawProductId);
    if (productId == null) return false;

    return _items.any((item) => _normalizeProductId(item['product_id']) == productId);
  }

  // Helper to safely parse and normalize product IDs to int
  int? _normalizeProductId(dynamic rawId) {
    if (rawId == null) return null;
    final cleaned = rawId.toString().replaceAll('gid://shopify/Product/', '').trim();
    return int.tryParse(cleaned);
  }
}
