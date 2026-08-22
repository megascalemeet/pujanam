import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/payment/payment_api_service.dart';
import '../models/payment/payment_models.dart';
import '../models/orders/order_models.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentApiService _apiService = PaymentApiService();

  bool _isLoading = false;
  String? _errorMessage;
  PaymentOptionsResponse? _paymentOptions;
  OrderSummaryResponse? _orderSummary;
  Order? _orderDetails;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PaymentOptionsResponse? get paymentOptions => _paymentOptions;
  OrderSummaryResponse? get orderSummary => _orderSummary;
  Order? get orderDetails => _orderDetails;

  // Simple UUID v4 generator
  String _generateUuidV4() {
    final Random random = Random.secure();
    final List<int> values =
        List<int>.generate(16, (i) => random.nextInt(256));

    // Set UUID v4 specific bits
    values[6] = (values[6] & 0x0f) | 0x40; // Version 4
    values[8] = (values[8] & 0x3f) | 0x80; // Variant 10xxxxxx

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      buffer.write(values[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  Future<void> fetchPaymentOptions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('checkout_session_token') ?? '';
      if (sessionToken.isEmpty) {
        _errorMessage =
            'Your cart session has expired. Please go back and try again.';
        return;
      }
      _paymentOptions = await _apiService.fetchPaymentOptions(sessionToken);
    } catch (_) {
      _errorMessage =
          'Unable to load payment methods. Please check your connection and try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PaymentInitiateResponse?> initiatePayment(
      String paymentMethod) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('checkout_session_token') ?? '';
      if (sessionToken.isEmpty) {
        _errorMessage =
            'Your cart session has expired. Please go back and try again.';
        return null;
      }
      final idempotencyKey = _generateUuidV4();
      final result = await _apiService.initiatePayment(
          sessionToken, paymentMethod, idempotencyKey);
      return result;
    } catch (_) {
      _errorMessage =
          'Could not initiate payment. Please try again or choose a different method.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PaymentVerifyResponse?> verifyPayment(
      Map<String, dynamic> verifyData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('checkout_session_token') ?? '';
      if (sessionToken.isEmpty) {
        _errorMessage =
            'Your cart session has expired. Please go back and try again.';
        return null;
      }
      final result =
          await _apiService.verifyPayment(sessionToken, verifyData);
      return result;
    } catch (_) {
      _errorMessage =
          'Payment verification failed. If money was deducted, please contact support.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> failPayment(Map<String, dynamic> failData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('checkout_session_token') ?? '';
      if (sessionToken.isEmpty) {
        _errorMessage =
            'Your cart session has expired. Please go back and try again.';
        return false;
      }
      return await _apiService.failPayment(sessionToken, failData);
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('checkout_session_token') ?? '';
      if (sessionToken.isEmpty) {
        _errorMessage =
            'We could not load your order details right now. Please check your orders section.';
        return;
      }
      _orderSummary = await _apiService.fetchOrderSummary(sessionToken);
    } catch (_) {
      _errorMessage =
          'We could not load your order details right now. Please check your orders section.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetails(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orderDetails = await _apiService.fetchOrderDetails(orderId);
    } catch (_) {
      _errorMessage =
          'Unable to load order details. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
