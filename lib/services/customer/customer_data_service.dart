// Service to fetch combined customer profile and addresses
import '../../models/profile/customer_data.dart';
import '../../services/customer/customer_api_service.dart';
import '../../services/profile/address_service.dart';

class CustomerDataService {
  final CustomerApiService _profileService = CustomerApiService();
  final AddressApiService _addressService = AddressApiService();

  Future<CustomerData> getCustomerData() async {
    final profile = await _profileService.getProfile();
    final addresses = await _addressService.getAddresses();
    return CustomerData(profile: profile, addresses: addresses);
  }
}
