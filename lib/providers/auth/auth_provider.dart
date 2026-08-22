import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
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

  Future<void> handleGuestLogin() async {
    debugPrint('========== GUEST LOGIN START ==========');

    try {
      final prefs = await SharedPreferences.getInstance();
      debugPrint('[GuestLogin] SharedPreferences initialized');

      // FCM Token
      final fcmToken = prefs.getString('fcmToken') ?? '';
      debugPrint('[GuestLogin] FCM Token: $fcmToken');

      // Guest ID
      String guestId = prefs.getString('guestId') ?? '';
      debugPrint('[GuestLogin] Existing Guest ID: $guestId');

      if (guestId.isEmpty) {
        guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';

        await prefs.setString('guestId', guestId);

        debugPrint('[GuestLogin] New Guest ID generated: $guestId');
      } else {
        debugPrint('[GuestLogin] Using existing Guest ID: $guestId');
      }

      // Device information
      final deviceInfo = DeviceInfoPlugin();

      String deviceModel = 'Unknown';
      String deviceType = Platform.isAndroid ? 'android' : 'ios';

      debugPrint('[GuestLogin] Device Type: $deviceType');

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;

        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';

        debugPrint(
          '[GuestLogin] Android Manufacturer: ${androidInfo.manufacturer}',
        );
        debugPrint('[GuestLogin] Android Model: ${androidInfo.model}');
        debugPrint('[GuestLogin] Device Model: $deviceModel');
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;

        deviceModel = iosInfo.name;

        debugPrint('[GuestLogin] iOS Device Name: ${iosInfo.name}');
        debugPrint('[GuestLogin] Device Model: $deviceModel');
      }

      const appVersion = '1.0.0';

      debugPrint('[GuestLogin] App Version: $appVersion');

      debugPrint('---------- API REQUEST ----------');
      debugPrint('[GuestLogin] fcmToken: $fcmToken');
      debugPrint('[GuestLogin] guestId: $guestId');
      debugPrint('[GuestLogin] deviceType: $deviceType');
      debugPrint('[GuestLogin] deviceModel: $deviceModel');
      debugPrint('[GuestLogin] appVersion: $appVersion');
      debugPrint('---------------------------------');

      final response = await _apiService.registerGuestFcmToken(
        fcmToken: fcmToken,
        guestId: guestId,
        deviceType: deviceType,
        deviceModel: deviceModel,
        appVersion: appVersion,
      );

      // debugPrint('[GuestLogin] API Response: $response.');

      debugPrint('========== GUEST LOGIN SUCCESS ==========');
    } catch (e, stackTrace) {
      debugPrint('========== GUEST LOGIN ERROR ==========');
      debugPrint('[GuestLogin] Error: $e');
      debugPrint('[GuestLogin] StackTrace: $stackTrace');
      debugPrint('========================================');
    }
  }
  // Future<void> handleGuestLogin() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final fcmToken = prefs.getString('fcmToken') ?? '';
  //
  //     // Generate a guest ID if not already present
  //     String guestId = prefs.getString('guestId') ?? '';
  //     if (guestId.isEmpty) {
  //       guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
  //       await prefs.setString('guestId', guestId);
  //     }
  //
  //     final deviceInfo = DeviceInfoPlugin();
  //     String deviceModel = 'Unknown';
  //     String deviceType = Platform.isAndroid ? 'android' : 'ios';
  //
  //     if (Platform.isAndroid) {
  //       final androidInfo = await deviceInfo.androidInfo;
  //       deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
  //     } else if (Platform.isIOS) {
  //       final iosInfo = await deviceInfo.iosInfo;
  //       deviceModel = iosInfo.name;
  //     }
  //
  //     await _apiService.registerGuestFcmToken(
  //       fcmToken: fcmToken,
  //       guestId: guestId,
  //       deviceType: deviceType,
  //       deviceModel: deviceModel,
  //       appVersion:
  //           '1.0.0', // You can use package_info_plus for a dynamic version
  //     );
  //   } catch (e) {
  //     debugPrint('Error in handleGuestLogin: $e');
  //   }
  // }

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
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'Failed to send OTP';
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

      if (response.token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        // Store the JWT token under both keys for compatibility with existing services.
        await prefs.setString('accessToken', response.token);
        await prefs.setString('platformToken', response.token);

        await prefs.setString('customer_id', response.user.id);
        await prefs.setString('mobileNumber', response.user.phone);
        await prefs.setString('email', response.user.email ?? '');

        // Determine a display name: prefer firstName, fallback to email prefix.
        String name = '';
        if (response.user.firstName.isNotEmpty) {
          name = response.user.firstName;
        } else if ((response.user.email ?? '').isNotEmpty &&
            (response.user.email ?? '').contains('@')) {
          name = (response.user.email ?? '').split('@')[0];
        }
        await prefs.setString('name', name);

        // Register Customer FCM Token
        final fcmToken = prefs.getString('fcmToken') ?? '';
        if (fcmToken.isNotEmpty) {
          final os = Platform.isAndroid ? 'Android' : 'iOS';
          final deviceType = Platform.isAndroid ? 'android' : 'ios';

          // Using a try-catch so FCM registration failure doesn't break the login flow
          try {
            await _apiService.registerCustomerFcmToken(
              fcmToken: fcmToken,
              deviceType: deviceType,
              token: response.token,
              os: os,
            );
          } catch (e) {
            debugPrint('Failed to register customer FCM token: $e');
          }
        }

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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    final fcmToken = prefs.getString('fcmToken') ?? '';

    if (token.isNotEmpty && fcmToken.isNotEmpty) {
      try {
        await _apiService.deleteCustomerFcmToken(
          fcmToken: fcmToken,
          token: token,
        );
      } catch (e) {
        debugPrint('Failed to delete customer FCM token: $e');
      }
    }

    // Clear all saved data
    await prefs.clear();

    // Reset provider state
    _isOtpSent = false;
    _errorMessage = null;
    notifyListeners();
  }
}
