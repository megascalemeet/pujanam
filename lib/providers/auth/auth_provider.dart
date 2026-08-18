import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth/auth_api_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();

  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isOtpSent => _isOtpSent;
  String? get errorMessage => _errorMessage;

  void resetOtpStatus() {
    _isOtpSent = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Future<bool> sendOtp(String phone) async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();
  //
  //   try {
  //     final response = await _apiService.sendOtp(phone);
  //     if (response['success'] == true) {
  //       _isOtpSent = true;
  //       _isLoading = false;
  //       notifyListeners();
  //       return true;
  //     } else {
  //       _errorMessage = response['message'] ?? 'Failed to send OTP';
  //       _isLoading = false;
  //       notifyListeners();
  //       return false;
  //     }
  //   } catch (e) {
  //     _errorMessage = 'An error occurred. Please check your connection.';
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }

  Future<bool> sendOtp(String phone) async {
    debugPrint('════════════════════════════════════════════');
    debugPrint('📱 SEND OTP START');
    debugPrint('📱 Phone: $phone');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('⏳ isLoading: $_isLoading');
    debugPrint('🧹 errorMessage reset: $_errorMessage');

    try {
      debugPrint('🚀 Calling _apiService.sendOtp()...');

      final response = await _apiService.sendOtp(phone);

      debugPrint('✅ API call completed');
      debugPrint('📦 Response type: ${response.runtimeType}');
      debugPrint('📦 Response: $response');

      debugPrint('🔍 Checking response success...');

      if (response['success'] == true) {
        debugPrint('✅ OTP SEND SUCCESS');
        debugPrint('✅ success: ${response['success']}');
        debugPrint('💬 message: ${response['message']}');

        _isOtpSent = true;
        _isLoading = false;

        debugPrint('🔐 isOtpSent: $_isOtpSent');
        debugPrint('⏹️ isLoading: $_isLoading');

        notifyListeners();

        debugPrint('🔔 notifyListeners() called');
        debugPrint('📱 SEND OTP END → TRUE');
        debugPrint('════════════════════════════════════════════');

        return true;
      } else {
        debugPrint('❌ OTP SEND FAILED');
        debugPrint('❌ success: ${response['success']}');
        debugPrint('💬 message: ${response['message']}');

        _errorMessage = response['message'] ?? 'Failed to send OTP';
        _isLoading = false;

        debugPrint('⚠️ errorMessage: $_errorMessage');
        debugPrint('⏹️ isLoading: $_isLoading');

        notifyListeners();

        debugPrint('🔔 notifyListeners() called');
        debugPrint('📱 SEND OTP END → FALSE');
        debugPrint('════════════════════════════════════════════');

        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('════════════════════════════════════════════');
      debugPrint('🔥 SEND OTP EXCEPTION');
      debugPrint('🔥 Error: $e');
      debugPrint('🔥 Error type: ${e.runtimeType}');
      debugPrint('📚 StackTrace:');
      debugPrint('$stackTrace');
      debugPrint('════════════════════════════════════════════');

      _errorMessage = 'An error occurred. Please check your connection.';
      _isLoading = false;

      debugPrint('⚠️ errorMessage: $_errorMessage');
      debugPrint('⏹️ isLoading: $_isLoading');

      notifyListeners();

      debugPrint('🔔 notifyListeners() called');
      debugPrint('📱 SEND OTP END → FALSE');

      return false;
    }
  }

  // Future<bool> verifyOtp(String phone, String otp) async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();
  //
  //   try {
  //     final response = await _apiService.verifyOtp(phone, otp);
  //     if (response['success'] == true) {
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('accessToken', response['token']);
  //
  //       final customer = response['customer'];
  //       if (customer != null) {
  //         await prefs.setString('customer_id', customer['id'].toString());
  //         await prefs.setString('mobileNumber', customer['phone'] ?? '');
  //         await prefs.setString('firstName', customer['first_name'] ?? '');
  //         await prefs.setString('lastName', customer['last_name'] ?? '');
  //         await prefs.setString(
  //           'name',
  //           '${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}'
  //               .trim(),
  //         );
  //         await prefs.setString('email', customer['email'] ?? '');
  //       }
  //
  //       _isLoading = false;
  //       notifyListeners();
  //       return true;
  //     } else {
  //       _errorMessage = response['message'] ?? 'Invalid OTP';
  //       _isLoading = false;
  //       notifyListeners();
  //       return false;
  //     }
  //   } catch (e) {
  //     _errorMessage = 'Verification failed. Please try again.';
  //     _isLoading = false;
  //     notifyListeners();
  //     return false;
  //   }
  // }
  Future<bool> verifyOtp(String phone, String otp) async {
    debugPrint('════════════════════════════════════════════');
    debugPrint('🔐 VERIFY OTP START');
    debugPrint('📱 Phone: $phone');
    debugPrint('🔢 OTP: $otp');

    _isLoading = true;
    _errorMessage = null;

    debugPrint('⏳ isLoading: $_isLoading');
    debugPrint('🧹 errorMessage reset: $_errorMessage');

    notifyListeners();
    debugPrint('🔔 notifyListeners() called');

    try {
      debugPrint('🚀 Calling _apiService.verifyOtp()...');

      final response = await _apiService.verifyOtp(phone, otp);

      debugPrint('✅ verifyOtp API call completed');
      debugPrint('📦 Response type: ${response.runtimeType}');
      debugPrint('📦 Full Response: $response');

      debugPrint('🔍 Response success: ${response['success']}');

      if (response['success'] == true) {
        debugPrint('════════════════════════════════════════════');
        debugPrint('✅ OTP VERIFICATION SUCCESS');
        debugPrint('════════════════════════════════════════════');

        // Token
        final token = response['token'];

        debugPrint('🔑 Token received: ${token != null}');
        debugPrint('🔑 Token length: ${token?.toString().length ?? 0}');

        // SharedPreferences
        debugPrint('💾 Getting SharedPreferences...');

        final prefs = await SharedPreferences.getInstance();

        debugPrint('✅ SharedPreferences initialized');

        if (token != null) {
          await prefs.setString('accessToken', token.toString());

          debugPrint('💾 accessToken saved successfully');
        } else {
          debugPrint('⚠️ WARNING: Token is NULL');
        }

        // Customer
        final customer = response['customer'];

        debugPrint('👤 Customer data exists: ${customer != null}');
        debugPrint('👤 Customer data: $customer');

        if (customer != null) {
          debugPrint('👤 Customer ID: ${customer['id']}');
          debugPrint('📱 Customer Phone: ${customer['phone']}');
          debugPrint('👤 First Name: ${customer['first_name']}');
          debugPrint('👤 Last Name: ${customer['last_name']}');
          debugPrint('📧 Email: ${customer['email']}');

          // Customer ID
          await prefs.setString('customer_id', customer['id'].toString());

          debugPrint('💾 customer_id saved');

          // Mobile Number
          await prefs.setString('mobileNumber', customer['phone'] ?? '');

          debugPrint('💾 mobileNumber saved');

          // First Name
          await prefs.setString('firstName', customer['first_name'] ?? '');

          debugPrint('💾 firstName saved');

          // Last Name
          await prefs.setString('lastName', customer['last_name'] ?? '');

          debugPrint('💾 lastName saved');

          // Full Name
          final fullName =
              '${customer['first_name'] ?? ''} '
                      '${customer['last_name'] ?? ''}'
                  .trim();

          debugPrint('👤 Full Name: $fullName');

          await prefs.setString('name', fullName);

          debugPrint('💾 name saved');

          // Email
          await prefs.setString('email', customer['email'] ?? '');

          debugPrint('💾 email saved');

          debugPrint('✅ All customer data saved successfully');
        } else {
          debugPrint('⚠️ Customer data is NULL');
          debugPrint('⚠️ Customer information was NOT saved');
        }

        _isLoading = false;

        debugPrint('⏹️ isLoading: $_isLoading');

        notifyListeners();

        debugPrint('🔔 notifyListeners() called');
        debugPrint('🎉 OTP VERIFICATION COMPLETED SUCCESSFULLY');
        debugPrint('📱 VERIFY OTP END → TRUE');
        debugPrint('════════════════════════════════════════════');

        return true;
      } else {
        debugPrint('════════════════════════════════════════════');
        debugPrint('❌ OTP VERIFICATION FAILED');

        debugPrint('❌ success: ${response['success']}');
        debugPrint('💬 API message: ${response['message']}');

        _errorMessage = response['message'] ?? 'Invalid OTP';
        _isLoading = false;

        debugPrint('⚠️ errorMessage: $_errorMessage');

        notifyListeners();

        debugPrint('📱 VERIFY OTP END → FALSE');
        debugPrint('════════════════════════════════════════════');

        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('════════════════════════════════════════════');
      debugPrint('🔥 VERIFY OTP EXCEPTION');
      debugPrint('════════════════════════════════════════════');

      debugPrint('🔥 Error: $e');
      debugPrint('🔥 Error Type: ${e.runtimeType}');
      debugPrint('📱 Phone: $phone');
      debugPrint('🔢 OTP: $otp');

      debugPrint('📚 StackTrace:');
      debugPrint('$stackTrace');

      _errorMessage = 'Verification failed. Please try again.';

      _isLoading = false;

      debugPrint('⚠️ errorMessage: $_errorMessage');
      debugPrint('⏹️ isLoading: $_isLoading');

      notifyListeners();

      debugPrint('🔔 notifyListeners() called');
      debugPrint('📱 VERIFY OTP END → FALSE');
      debugPrint('════════════════════════════════════════════');

      return false;
    }
  }
}
