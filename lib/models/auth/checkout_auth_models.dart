class SendCheckoutOtpResponse {
  final bool success;
  final String message;
  final SendCheckoutOtpData? data;

  SendCheckoutOtpResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SendCheckoutOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendCheckoutOtpResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? SendCheckoutOtpData.fromJson(json['data']) : null,
    );
  }
}

class SendCheckoutOtpData {
  final String phone;
  final String channel;

  SendCheckoutOtpData({
    required this.phone,
    required this.channel,
  });

  factory SendCheckoutOtpData.fromJson(Map<String, dynamic> json) {
    return SendCheckoutOtpData(
      phone: json['phone'] ?? '',
      channel: json['channel'] ?? '',
    );
  }
}

class VerifyCheckoutOtpResponse {
  final String accessToken;
  final String platformToken;
  final CheckoutAuthUser user;

  VerifyCheckoutOtpResponse({
    required this.accessToken,
    required this.platformToken,
    required this.user,
  });

  factory VerifyCheckoutOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return VerifyCheckoutOtpResponse(
      accessToken: data['accessToken'] ?? '',
      platformToken: data['platformToken'] ?? '',
      user: CheckoutAuthUser.fromJson(data['user'] ?? {}),
    );
  }
}

class CheckoutAuthUser {
  final String id;
  final String phone;
  final String email;

  CheckoutAuthUser({
    required this.id,
    required this.phone,
    required this.email,
  });

  factory CheckoutAuthUser.fromJson(Map<String, dynamic> json) {
    return CheckoutAuthUser(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}
