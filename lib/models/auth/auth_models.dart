class SendOtpResponse {
  final bool success;
  final String message;
  final SendOtpData? data;

  SendOtpResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? SendOtpData.fromJson(json['data']) : null,
    );
  }
}

class SendOtpData {
  final String phone;
  final String channel;

  SendOtpData({
    required this.phone,
    required this.channel,
  });

  factory SendOtpData.fromJson(Map<String, dynamic> json) {
    return SendOtpData(
      phone: json['phone'] ?? '',
      channel: json['channel'] ?? '',
    );
  }
}

class VerifyOtpResponse {
  // New API returns a single token field instead of accessToken/platformToken.
  final String token;
  // Customer information returned under "customer".
  final AuthUser user;

  VerifyOtpResponse({
    required this.token,
    required this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    // The API may wrap data under "data" or return flat.
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return VerifyOtpResponse(
      token: data['token'] ?? '',
      user: AuthUser.fromJson(data['customer'] ?? {}),
    );
  }
}

class AuthUser {
  final String id;
  final String firstName;
  final String? lastName;
  final String phone;
  final String? email;

  AuthUser({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.phone,
    this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'],
      phone: json['phone'] ?? '',
      email: json['email'],
    );
  }
}
