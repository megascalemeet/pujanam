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

  Future<bool> sendOtp(String phone) async {
    debugPrint('════════════════════════════════════════════');
    debugPrint('📱 SEND OTP START');
    debugPrint('📱 Phone: $phone');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.sendOtp(phone);

      if (response.success) {
        _isOtpSent = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message.isNotEmpty ? response.message : 'Failed to send OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    debugPrint('════════════════════════════════════════════');
    debugPrint('🔐 VERIFY OTP START');
    debugPrint('📱 Phone: $phone');
    debugPrint('🔢 OTP: $otp');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.verifyOtp(phone, otp);

      if (response.accessToken.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', response.accessToken);
        await prefs.setString('platformToken', response.platformToken);
        await prefs.setString('customer_id', response.user.id);
        await prefs.setString('mobileNumber', response.user.phone);
        await prefs.setString('email', response.user.email);
        
        // Generate a fallback name from the email prefix if name is needed
        String name = '';
        if (response.user.email.isNotEmpty && response.user.email.contains('@')) {
          name = response.user.email.split('@')[0];
        }
        await prefs.setString('name', name);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Verification failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

