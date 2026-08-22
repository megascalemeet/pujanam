import '../../models/customer/customer_address.dart';
import '../../models/customer/customer_profile.dart';

class CustomerData {
  final CustomerProfile profile;
  final List<CustomerAddress> addresses;

  CustomerData({required this.profile, required this.addresses});
}
