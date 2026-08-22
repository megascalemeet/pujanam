class Address {
  final int? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String? country;
  final String pincode;
  final bool? isDefault;

  Address({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    this.country,
    required this.pincode,
    this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as int?,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      addressLine1: json['address_line1'] ?? '',
      addressLine2: json['address_line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'],
      pincode: json['pincode'] ?? '',
      isDefault: json['is_default'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      'city': city,
      'state': state,
      if (country != null) 'country': country,
      'pincode': pincode,
      if (isDefault != null) 'is_default': isDefault,
    };
  }
}
