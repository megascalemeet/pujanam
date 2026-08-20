import 'package:flutter/material.dart';

import '../../models/orders/order_models.dart';
import '../../services/orders/order_api_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderApiService _apiService = OrderApiService();

  bool _isLoading = false;
  List<Order> _orders = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Order> get orders => _orders;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.fetchOrders();
      if (response.success) {
        _orders = response.items;
      } else {
        _errorMessage = 'Failed to fetch orders';
      }
    } catch (e) {
      _errorMessage = 'An error occurred while fetching orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reorderItems(List<CartItemInput> items) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = AddToCartRequest(currency: 'INR', cartItems: items);
      final response = await _apiService.addToCart(request);
      if (response.success && response.data != null) {
        // Reorder succeeded, return true so UI can navigate or notify
        return true;
      } else {
        _errorMessage = 'Failed to add items to cart';
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
