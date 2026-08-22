import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/checkout/coupon_model.dart';
import '../../services/checkout/checkout_api_service.dart';

class CheckoutProvider with ChangeNotifier {
  final CheckoutApiService _apiService = CheckoutApiService();

  List<Coupon> _coupons = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Applied coupon state
  String? _appliedCouponCode;
  double _discountAmount = 0.0;
  bool _isCouponLoading = false;
  String? _couponError;
  String? _couponSuccess;

  List<Coupon> get coupons => _coupons;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get appliedCouponCode => _appliedCouponCode;
  double get discountAmount => _discountAmount;
  bool get isCouponLoading => _isCouponLoading;
  String? get couponError => _couponError;
  String? get couponSuccess => _couponSuccess;
  bool get hasCouponApplied => _appliedCouponCode != null;

  Future<void> fetchCoupons() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.fetchCoupons();
      if (response.success) {
        _coupons = response.coupons;
      } else {
        _errorMessage = 'Could not load coupons. Please try again.';
      }
    } catch (_) {
      _errorMessage = 'Could not load coupons. Please check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddressToCheckout(Map<String, dynamic> addressData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('checkout_session_token');

      if (sessionToken == null || sessionToken.isEmpty) {
        _errorMessage = 'Your cart session has expired. Please add items again.';
        return false;
      }

      // Add address to checkout session
      final response =
          await _apiService.addAddressToCheckout(sessionToken, addressData);
      if (response['success'] == true) {
        // If "saveToUserAddresses" is true, write to customer portal profile addresses list
        if (addressData['saveToUserAddresses'] == true) {
          final platformToken = prefs.getString('platformToken') ?? '';
          if (platformToken.isNotEmpty) {
            try {
              final portalAddressData = {
                "firstName": addressData['firstName'],
                "lastName": addressData['lastName'],
                "addressLine1": addressData['address1'],
                "city": addressData['city'],
                "state": addressData['province'],
                "postalCode": addressData['zip'],
                "countryCode": "IN", // default to India
                "phoneNumber": addressData['phone'],
                "isDefault": true,
                "addressType": "shipping"
              };
              await _apiService.saveAddressToCustomerPortal(platformToken, portalAddressData);
            } catch (e) {
              debugPrint('Failed to save to customer portal addresses: $e');
              // We do not fail the checkout flow if saving address failed to avoid blocking checkout.
            }
          }
        }
        return true;
      } else {
        _errorMessage = 'Could not save your address. Please try again.';
        return false;
      }
    } catch (_) {
      _errorMessage = 'Could not save your address. Please check your connection and try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Apply a coupon to the active checkout session.
  /// Returns true on success, false on failure.
  Future<bool> applyCoupon(String couponCode) async {
    if (couponCode.trim().isEmpty) {
      _couponError = 'Please enter a coupon code.';
      _couponSuccess = null;
      notifyListeners();
      return false;
    }

    _isCouponLoading = true;
    _couponError = null;
    _couponSuccess = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('checkout_session_token');

      if (sessionToken == null || sessionToken.isEmpty) {
        _couponError = 'Your cart session has expired. Please add items again.';
        return false;
      }

      final response = await _apiService.applyCoupon(sessionToken, couponCode.trim().toUpperCase());

      if (response['success'] == true) {
        _appliedCouponCode = couponCode.trim().toUpperCase();
        // Extract discount from response if available
        final data = response['data'] as Map<String, dynamic>? ?? {};
        _discountAmount = (data['discount'] ?? data['discountAmount'] ?? 0.0).toDouble();
        _couponSuccess = 'Coupon "$_appliedCouponCode" applied successfully!';
        _couponError = null;
        return true;
      } else {
        final msg = response['message'] ?? response['error'];
        _couponError = (msg != null && msg.toString().isNotEmpty)
            ? msg.toString()
            : 'This coupon is not valid. Please try another.';
        return false;
      }
    } catch (e) {
      // Show a clean version of caught exceptions (server messages are safe)
      final raw = e.toString().replaceFirst('Exception: ', '');
      _couponError = raw.isNotEmpty && raw.length < 120
          ? raw
          : 'This coupon could not be applied. Please try again.';
      return false;
    } finally {
      _isCouponLoading = false;
      notifyListeners();
    }
  }

  /// Remove the applied coupon from the session.
  Future<void> removeCoupon() async {
    _isCouponLoading = true;
    _couponError = null;
    _couponSuccess = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString('checkout_session_token');

      if (sessionToken == null || sessionToken.isEmpty) return;
      if (_appliedCouponCode == null) return;

      await _apiService.removeCoupon(sessionToken, _appliedCouponCode!);
    } catch (_) {
      // Ignore errors on remove — still clear locally
    } finally {
      _appliedCouponCode = null;
      _discountAmount = 0.0;
      _isCouponLoading = false;
      notifyListeners();
    }
  }

  void clearCouponMessages() {
    _couponError = null;
    _couponSuccess = null;
    notifyListeners();
  }
}
