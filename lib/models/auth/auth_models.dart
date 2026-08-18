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
  final String accessToken;
  final String platformToken;
  final AuthUser user;

  VerifyOtpResponse({
    required this.accessToken,
    required this.platformToken,
    required this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return VerifyOtpResponse(
      accessToken: data['accessToken'] ?? '',
      platformToken: data['platformToken'] ?? '',
      user: AuthUser.fromJson(data['user'] ?? {}),
    );
  }
}

class AuthUser {
  final String id;
  final String phone;
  final String email;

  AuthUser({
    required this.id,
    required this.phone,
    required this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
