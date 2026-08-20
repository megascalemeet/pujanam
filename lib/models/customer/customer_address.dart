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
      firstName: data['firstName']?.toString() ?? '',
      lastName: data['lastName']?.toString() ?? '',
      addressLine1: data['addressLine1']?.toString() ?? '',
      addressLine2: data['addressLine2']?.toString(),
      addressType: data['addressType']?.toString() ?? 'shipping',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postalCode: data['postalCode']?.toString() ?? '',
      countryCode: data['countryCode']?.toString() ?? '',
      phoneNumber: data['phoneNumber']?.toString() ?? '',
      isDefault: data['isDefault'] == true,
      createdAt:
          DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(data['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'addressLine1': addressLine1,
    if (addressLine2 != null) 'addressLine2': addressLine2,
    'addressType': addressType,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'countryCode': countryCode,
    'phoneNumber': phoneNumber,
    'isDefault': isDefault,
  };
}
