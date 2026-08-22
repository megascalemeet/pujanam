import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/customer/customer_address.dart';
import '../../models/customer/customer_profile.dart';
import '../../services/customer/customer_api_service.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerApiService _apiService = CustomerApiService();

  CustomerProfile? _profile;
  List<CustomerAddress> _addresses = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  CustomerProfile? get profile => _profile;
  List<CustomerAddress> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadCustomer() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final profileFuture = _apiService.getProfile();
      final addressesFuture = _apiService.getAddresses();
      final results = await Future.wait([profileFuture, addressesFuture]);
      _profile = results[0] as CustomerProfile;
      _addresses = results[1] as List<CustomerAddress>;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(
    String firstName,
    String lastName, {
    String? email,
    String? phoneNumber,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await _apiService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );
      await _updateStoredContactDetails();
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfileAndAddress({
    required String firstName,
    required String lastName,
    String? email,
    String? phoneNumber,
    CustomerAddress? address,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await _apiService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );
      await _updateStoredContactDetails();
      if (address != null) {
        final savedAddress = address.id.isEmpty
            ? await _apiService.addAddress(address)
            : await _apiService.updateAddress(address.id, address);
        final index = _addresses.indexWhere(
          (item) => item.id == savedAddress.id,
        );
        if (index == -1) {
          _addresses.add(savedAddress);
        } else {
          _addresses[index] = savedAddress;
        }
      }
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Keeps login-related contact values in sync after a successful profile save.
  Future<void> _updateStoredContactDetails() async {
    final profile = _profile;
    if (profile == null) return;

    final preferences = await SharedPreferences.getInstance();
    final email = profile.email;
    if (email != null &&
        email.isNotEmpty &&
        email != preferences.getString('email')) {
      await preferences.setString('email', email);
    }
    if (profile.phoneNumber.isNotEmpty &&
        profile.phoneNumber != preferences.getString('mobileNumber')) {
      await preferences.setString('mobileNumber', profile.phoneNumber);
    }
  }
}
