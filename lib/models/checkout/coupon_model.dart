class Coupon {
  final String code;
  final String name;
  final String discountType;
  final String value;
  final int? minOrderAmount;
  final bool isStackable;
  final int priority;

  Coupon({
    required this.code,
    required this.name,
    required this.discountType,
    required this.value,
    this.minOrderAmount,
    required this.isStackable,
    required this.priority,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    int? minOrderAmt;
    if (json['targetingRules'] != null && json['targetingRules']['minOrderAmount'] != null) {
      minOrderAmt = int.tryParse(json['targetingRules']['minOrderAmount'].toString());
    }
    return Coupon(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? '',
      value: json['value']?.toString() ?? '0',
      minOrderAmount: minOrderAmt,
      isStackable: json['isStackable'] as bool? ?? false,
      priority: int.tryParse(json['priority']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'discountType': discountType,
      'value': value,
      'targetingRules': minOrderAmount != null ? {'minOrderAmount': minOrderAmount} : null,
      'isStackable': isStackable,
      'priority': priority,
    };
  }
}

class CouponResponse {
  final bool success;
  final List<Coupon> coupons;

  CouponResponse({
    required this.success,
    required this.coupons,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return CouponResponse(
      success: json['success'] as bool? ?? false,
      coupons: list.map((c) => Coupon.fromJson(c as Map<String, dynamic>)).toList(),
    );
  }
}
