class CartItem {
  final String productId;
  final String variantId;
  final double price;
  final double compareAtPrice;
  final int quantity;
  final String sku;
  final String title;
  final String imageUrl;
  final String weight;

  CartItem({
    required this.productId,
    required this.variantId,
    required this.price,
    required this.compareAtPrice,
    required this.quantity,
    required this.sku,
    required this.title,
    required this.imageUrl,
    required this.weight,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId']?.toString() ?? '',
      variantId: json['variantId']?.toString() ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      compareAtPrice: double.tryParse(json['compareAtPrice']?.toString() ?? '') ?? double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
      sku: json['sku']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'variantId': variantId,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'quantity': quantity,
      'sku': sku,
      'title': title,
      'imageUrl': imageUrl,
      'weight': weight,
    };
  }

  CartItem copyWith({
    String? productId,
    String? variantId,
    double? price,
    double? compareAtPrice,
    int? quantity,
    String? sku,
    String? title,
    String? imageUrl,
    String? weight,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      quantity: quantity ?? this.quantity,
      sku: sku ?? this.sku,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      weight: weight ?? this.weight,
    );
  }
}

class CheckoutSessionResponse {
  final bool success;
  final String? sessionId;
  final String? token;
  final double grandTotal;
  final double subtotal;
  final String currency;
  final String status;
  final List<CartItem>? items;

  CheckoutSessionResponse({
    required this.success,
    this.sessionId,
    this.token,
    required this.grandTotal,
    this.subtotal = 0.0,
    required this.currency,
    required this.status,
    this.items,
  });

  factory CheckoutSessionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final checkout = data['checkout'] as Map<String, dynamic>? ?? {};
    final itemsList = checkout['checkoutItemsList'] as List<dynamic>? ?? [];
    final parsedItems = itemsList.map((itemJson) {
      return CartItem(
        productId: itemJson['productId']?.toString() ?? '',
        variantId: itemJson['variantId']?.toString() ?? '',
        price: double.tryParse(itemJson['price']?.toString() ?? '0') ?? 0.0,
        compareAtPrice: double.tryParse(itemJson['compareAtPrice']?.toString() ?? '') ?? double.tryParse(itemJson['price']?.toString() ?? '0') ?? 0.0,
        quantity: int.tryParse(itemJson['quantity']?.toString() ?? '1') ?? 1,
        sku: itemJson['sku']?.toString() ?? '',
        title: itemJson['title']?.toString() ?? '',
        imageUrl: itemJson['imageUrl']?.toString() ?? '',
        weight: itemJson['variantTitle']?.toString() ?? '',
      );
    }).toList();

    return CheckoutSessionResponse(
      success: json['success'] ?? false,
      sessionId: (checkout['id'] ?? data['sessionId'])?.toString(),
      token: (data['sessionToken'] ?? data['token'])?.toString(),
      grandTotal: double.tryParse((checkout['total'] ?? checkout['grandTotal'] ?? '0.00').toString()) ?? 0.0,
      subtotal: double.tryParse((checkout['subtotal'] ?? '0.00').toString()) ?? 0.0,
      currency: checkout['currency']?.toString() ?? 'INR',
      status: checkout['status']?.toString() ?? 'active',
      items: parsedItems,
    );
  }
}
