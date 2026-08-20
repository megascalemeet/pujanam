import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/cart/cart_models.dart';
import '../../services/cart/cart_api_service.dart';

class CartProvider with ChangeNotifier {
  final CartApiService _apiService = CartApiService();
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _sessionToken;
  String? _sessionId;
  double _checkoutTotal = 0.0;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get sessionToken => _sessionToken;
  String? get sessionId => _sessionId;
  double get checkoutTotal => _checkoutTotal;

  double get subtotal {
    double total = 0.0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  Future<void> loadCart() => fetchAndUpdateFromSession();

  Future<void> fetchAndUpdateFromSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionToken = prefs.getString('checkout_session_token');
      _sessionId = prefs.getString('checkout_session_id');

      if (_sessionToken != null && _sessionToken!.isNotEmpty) {
        final response = await _apiService.getCheckoutState(_sessionToken!);
        if (response.success && response.items != null) {
          _items = response.items!;
          _checkoutTotal = response.grandTotal;
          await _saveCart();
          _errorMessage = null;
        } else {
          // If session expired or failed, load local cart
          final cartString = prefs.getString('local_cart');
          if (cartString != null && cartString.isNotEmpty) {
            final List<dynamic> decoded = json.decode(cartString);
            _items = decoded.map((item) => CartItem.fromJson(item)).toList();
          } else {
            _items = [];
          }
        }
      } else {
        final cartString = prefs.getString('local_cart');
        if (cartString != null && cartString.isNotEmpty) {
          final List<dynamic> decoded = json.decode(cartString);
          _items = decoded.map((item) => CartItem.fromJson(item)).toList();
        } else {
          _items = [];
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load session cart: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('local_cart', cartString);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<bool> syncSession() async {
    if (_items.isEmpty) {
      _sessionToken = null;
      _sessionId = null;
      _checkoutTotal = 0.0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('checkout_session_token');
      await prefs.remove('checkout_session_id');
      notifyListeners();
      return true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('checkout_session_token');
      if (savedToken != null && savedToken.isNotEmpty) {
        _sessionToken = savedToken;
      }

      CheckoutSessionResponse response;
      if (_sessionToken != null && _sessionToken!.isNotEmpty) {
        response = await _apiService.updateCartItems(_sessionToken!, _items);
        if (!response.success) {
          debugPrint('Update items failed, falling back to create new session');
          response = await _apiService.createCheckoutSession(_items);
        }
      } else {
        response = await _apiService.createCheckoutSession(_items);
      }

      if (response.success) {
        if (response.token != null) {
          _sessionToken = response.token;
          await prefs.setString('checkout_session_token', _sessionToken!);
        }
        if (response.sessionId != null) {
          _sessionId = response.sessionId;
          await prefs.setString('checkout_session_id', _sessionId!);
        }
        _checkoutTotal = response.grandTotal;
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = 'Failed to synchronize checkout session';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error during sync: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(CartItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      final wasEmpty = _items.isEmpty;

      final index = _items.indexWhere(
          (i) => i.productId == item.productId && i.weight == item.weight);

      if (index >= 0) {
        final existingItem = _items[index];
        _items[index] = existingItem.copyWith(
          quantity: existingItem.quantity + item.quantity,
        );
      } else {
        _items.add(item);
      }

      await _saveCart();
      final prefs = await SharedPreferences.getInstance();

      if (wasEmpty || _sessionToken == null) {
        final response = await _apiService.createCheckoutSession(_items);
        if (response.success && response.token != null) {
          _sessionToken = response.token;
          _sessionId = response.sessionId;
          _checkoutTotal = response.grandTotal;
          await prefs.setString('checkout_session_token', _sessionToken!);
          if (_sessionId != null) {
            await prefs.setString('checkout_session_id', _sessionId!);
          }
        }
      } else {
        final response = await _apiService.updateCartItems(_sessionToken!, _items);
        if (response.success) {
          _checkoutTotal = response.grandTotal;
        } else {
          final newResponse = await _apiService.createCheckoutSession(_items);
          if (newResponse.success && newResponse.token != null) {
            _sessionToken = newResponse.token;
            _sessionId = newResponse.sessionId;
            _checkoutTotal = newResponse.grandTotal;
            await prefs.setString('checkout_session_token', _sessionToken!);
            if (_sessionId != null) {
              await prefs.setString('checkout_session_id', _sessionId!);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String productId, String weight, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId, weight);
      return;
    }

    final index = _items.indexWhere(
        (i) => i.productId == productId && i.weight == weight);

    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> updateQuantityAndSync(String productId, String weight, int quantity) async {
    if (quantity <= 0) {
      await removeItemAndSync(productId, weight);
      return;
    }

    final index = _items.indexWhere(
        (i) => i.productId == productId && i.weight == weight);

    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      await _saveCart();
      await syncSession();
    }
  }

  Future<void> removeItem(String productId, String weight) async {
    _items.removeWhere((i) => i.productId == productId && i.weight == weight);
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeItemAndSync(String productId, String weight) async {
    _items.removeWhere((i) => i.productId == productId && i.weight == weight);
    await _saveCart();
    await syncSession();
  }

  Future<void> clearCart() async {
    _items.clear();
    _sessionToken = null;
    _sessionId = null;
    _checkoutTotal = 0.0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('local_cart');
    await prefs.remove('checkout_session_token');
    await prefs.remove('checkout_session_id');
    notifyListeners();
  }

  Future<bool> proceedToCheckout() async {
    return await syncSession();
  }
}
