class ShippingOption {
  final String id;
  final String name;
  final String code;
  final String? type;
  final double price;
  final int? estimatedDays;
  final String? description;
  final int? displayOrder;

  ShippingOption({
    required this.id,
    required this.name,
    required this.code,
    this.type,
    required this.price,
    this.estimatedDays,
    this.description,
    this.displayOrder,
  });

  factory ShippingOption.fromJson(Map<String, dynamic> json) {
    return ShippingOption(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      type: json['type'] as String?,
      price: (json['price'] as num).toDouble(),
      estimatedDays: json['estimatedDays'] as int?,
      description: json['description'] as String?,
      displayOrder: json['displayOrder'] as int?,
    );
  }
}

class ShippingOptionsResponse {
  final bool success;
  final List<ShippingOption> options;
  final ShippingOption? applied;
  final double? totalWeightKg;
  final String? selectedMethodId;
  final bool? codAvailable;

  ShippingOptionsResponse({
    required this.success,
    required this.options,
    this.applied,
    this.totalWeightKg,
    this.selectedMethodId,
    this.codAvailable,
  });

  factory ShippingOptionsResponse.fromJson(Map<String, dynamic> json) {
    var data = json['data'] as Map<String, dynamic>? ?? {};
    
    // Handle doubly-nested data from the backend
    if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
      data = data['data'] as Map<String, dynamic>;
    }
    
    return ShippingOptionsResponse(
      success: json['success'] as bool? ?? false,
      options: (data['options'] as List<dynamic>?)
              ?.map((e) => ShippingOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      applied: data['applied'] != null
          ? ShippingOption.fromJson(data['applied'] as Map<String, dynamic>)
          : null,
      totalWeightKg: (data['totalWeightKg'] as num?)?.toDouble(),
      selectedMethodId: data['selectedMethodId'] as String?,
      codAvailable: data['codAvailable'] as bool?,
    );
  }
}
