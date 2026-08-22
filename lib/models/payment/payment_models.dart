class PaymentMethodOption {
  final String id;
  final String title;
  final String type;
  final String? description;
  final String? icon;

  PaymentMethodOption({
    required this.id,
    required this.title,
    required this.type,
    this.description,
    this.icon,
  });

  factory PaymentMethodOption.fromJson(Map<String, dynamic> json) {
    return PaymentMethodOption(
      id: json['id'] ?? '',
      title: json['name'] ?? json['title'] ?? '',
      type: json['code'] ?? json['type'] ?? '',
      description: json['description'],
      icon: json['icon'],
    );
  }
}

class PricingSummary {
  final double subtotal;
  final double discount;
  final double total;
  final String currency;
  final String? offerLabel;
  final double savings;

  PricingSummary({
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.currency,
    this.offerLabel,
    required this.savings,
  });

  factory PricingSummary.fromJson(Map<String, dynamic> json) {
    final originalAmount = (json['originalAmount'] ?? 0.0).toDouble();
    // Default to the first method's discountedAmount if possible, otherwise originalAmount
    final paymentMethods = json['paymentMethods'] as List? ?? [];
    double discountedAmount = originalAmount;
    double savings = 0.0;
    String offerLabel = '';
    if (paymentMethods.isNotEmpty) {
      final firstMethod = paymentMethods.first;
      discountedAmount = (firstMethod['discountedAmount'] ?? originalAmount).toDouble();
      savings = (firstMethod['savings'] ?? 0.0).toDouble();
      offerLabel = firstMethod['offerLabel'] ?? '';
    }

    return PricingSummary(
      subtotal: originalAmount,
      discount: savings,
      total: discountedAmount,
      currency: json['currency'] ?? 'INR',
      offerLabel: offerLabel,
      savings: savings,
    );
  }
}

class PaymentOptionsResponse {
  final bool success;
  final List<PaymentMethodOption> methods;
  final PricingSummary summary;

  PaymentOptionsResponse({
    required this.success,
    required this.methods,
    required this.summary,
  });

  factory PaymentOptionsResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] ?? false;
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final methodsList = data['paymentMethods'] as List? ?? [];
    return PaymentOptionsResponse(
      success: success,
      methods: methodsList.map((m) => PaymentMethodOption.fromJson(m)).toList(),
      summary: PricingSummary.fromJson(data),
    );
  }
}

class EasebuzzPaymentData {
  final String redirectUrl;
  final String txnid;
  final String accessKey;
  final String launchMode;

  EasebuzzPaymentData({
    required this.redirectUrl,
    required this.txnid,
    required this.accessKey,
    required this.launchMode,
  });

  factory EasebuzzPaymentData.fromJson(Map<String, dynamic> json) {
    return EasebuzzPaymentData(
      redirectUrl: json['redirectUrl'] ?? json['redirect_url'] ?? '',
      txnid: json['txnid'] ?? '',
      accessKey: json['accessKey'] ?? json['access_key'] ?? '',
      launchMode: json['launchMode'] ?? json['launch_mode'] ?? 'iframe',
    );
  }
}

class PaymentInitiateResponse {
  final bool success;
  final String gateway;
  final String launchType;
  final String paymentId;
  final String orderNumber;
  final EasebuzzPaymentData? easebuzz;

  PaymentInitiateResponse({
    required this.success,
    required this.gateway,
    required this.launchType,
    required this.paymentId,
    required this.orderNumber,
    this.easebuzz,
  });

  factory PaymentInitiateResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return PaymentInitiateResponse(
      success: json['success'] ?? false,
      gateway: data['gateway'] ?? '',
      launchType: data['launchType'] ?? '',
      paymentId: data['paymentId'] ?? '',
      orderNumber: data['orderNumber'] ?? '',
      easebuzz: data['easebuzz'] != null ? EasebuzzPaymentData.fromJson(data['easebuzz']) : null,
    );
  }
}

class PaymentVerifyResponse {
  final bool success;
  final String? message;
  final String? orderId;

  PaymentVerifyResponse({
    required this.success,
    this.message,
    this.orderId,
  });

  factory PaymentVerifyResponse.fromJson(Map<String, dynamic> json) {
    bool isSuccess = false;
    if (json['success'] == true) {
      if (json['data'] != null && json['data'] is Map && json['data']['success'] != null) {
        isSuccess = json['data']['success'] == true;
      } else {
        isSuccess = true;
      }
    }

    return PaymentVerifyResponse(
      success: isSuccess,
      message: json['message'] ?? json['data']?['message'],
      orderId: json['orderId'] ?? json['data']?['orderId'],
    );
  }
}

class OrderSummaryResponse {
  final bool success;
  final String orderNumber;
  final double amountPaid;
  final String paymentMethod;
  final String orderDate;

  OrderSummaryResponse({
    required this.success,
    required this.orderNumber,
    required this.amountPaid,
    required this.paymentMethod,
    required this.orderDate,
  });

  factory OrderSummaryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return OrderSummaryResponse(
      success: json['success'] ?? false,
      orderNumber: data['orderNumber'] ?? '',
      amountPaid: (data['amountPaid'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      orderDate: data['orderDate'] ?? '',
    );
  }
}
