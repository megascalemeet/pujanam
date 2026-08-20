class CustomerProfile {
  final String id;
  final String? email;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final bool isVerified;
  final DateTime createdAt;

  CustomerProfile({
    required this.id,
    this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.isVerified,
    required this.createdAt,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return CustomerProfile(
      id: data['id'] ?? '',
      email: data['email'],
      phoneNumber: data['phoneNumber'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      isVerified: data['isVerified'] ?? false,
      createdAt: DateTime.parse(
        data['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
