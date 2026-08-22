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
      id: data['id']?.toString() ?? '',
      email: data['email'],
      phoneNumber: (data['phone'] ?? data['phoneNumber'] ?? '').toString(),
      firstName: (data['first_name'] ?? data['firstName'] ?? '').toString(),
      lastName: (data['last_name'] ?? data['lastName'] ?? '').toString(),
      isVerified: data['isVerified'] ?? false,
      createdAt: DateTime.parse(
        data['created_at'] ??
            data['createdAt'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }
}
