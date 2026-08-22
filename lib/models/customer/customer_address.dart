class CustomerAddress {
  final String id;
  final String firstName;
  final String lastName;
  final String addressLine1;
  final String? addressLine2;
  final String addressType;
  final String city;
  final String state;
  final String postalCode;
  final String countryCode;
  final String phoneNumber;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerAddress({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    this.addressLine2,
    required this.addressType,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.countryCode,
    required this.phoneNumber,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return CustomerAddress(
      id: data['id']?.toString() ?? '',
      firstName: (data['first_name'] ?? data['firstName'] ?? '').toString(),
      lastName: (data['last_name'] ?? data['lastName'] ?? '').toString(),
      addressLine1: (data['address_line1'] ?? data['addressLine1'] ?? '')
          .toString(),
      addressLine2: (data['address_line2'] ?? data['addressLine2'])?.toString(),
      addressType: data['addressType']?.toString() ?? 'shipping',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postalCode: (data['pincode'] ?? data['postalCode'] ?? '').toString(),
      countryCode: (data['country'] ?? data['countryCode'] ?? '').toString(),
      phoneNumber: (data['phone'] ?? data['phoneNumber'] ?? '').toString(),
      isDefault: data['is_default'] == true || data['isDefault'] == true,
      createdAt:
          DateTime.tryParse(
            (data['created_at'] ?? data['createdAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(
            (data['updated_at'] ?? data['updatedAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'address_line1': addressLine1,
    if (addressLine2 != null) 'address_line2': addressLine2,
    'city': city,
    'state': state,
    'pincode': postalCode,
    'country': countryCode,
    'phone': phoneNumber,
    'is_default': isDefault,
    'addressType': addressType,
  };
}
