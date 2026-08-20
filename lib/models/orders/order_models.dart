class MergedOrdersResponse {
  final bool success;
  final List<Order> items;

  MergedOrdersResponse({required this.success, required this.items});

  factory MergedOrdersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final itemsList = data['items'] as List? ?? [];
    return MergedOrdersResponse(
      success: json['success'] ?? false,
      items: itemsList.map((item) => Order.fromJson(item)).toList(),
    );
  }
}

class Order {
  final String id;
  final String source;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final String totalPrice;
  final String currency;
  final String createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.source,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.totalPrice,
    required this.currency,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    return Order(
      id: json['id'] ?? '',
      source: json['source'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: json['status'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      totalPrice: json['totalPrice'] ?? '0.00',
      currency: json['currency'] ?? 'INR',
      createdAt: json['createdAt'] ?? '',
      items: itemsList.map((item) => OrderItem.fromJson(item)).toList(),
    );
  }
}

class OrderItem {
  final String title;
  final int quantity;
  final String price;
  final String? imageUrl;

  OrderItem({
    required this.title,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      title: json['title'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: json['price'] ?? '0.00',
      imageUrl: json['imageUrl'],
    );
  }
}

class AddToCartRequest {
  final String currency;
  final List<CartItemInput> cartItems;

  AddToCartRequest({required this.currency, required this.cartItems});

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
    };
  }
}

class CartItemInput {
  final String productId;
  final String variantId;
  final double price;
  final int quantity;
  final String sku;
  final String title;

  CartItemInput({
    required this.productId,
    required this.variantId,
    required this.price,
    required this.quantity,
    required this.sku,
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'variantId': variantId,
      'price': price,
      'quantity': quantity,
      'sku': sku,
      'title': title,
    };
  }
}

class AddToCartResponse {
  final bool success;
  final AddToCartData? data;

  AddToCartResponse({required this.success, this.data});

  factory AddToCartResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>?;
    return AddToCartResponse(
      success: json['success'] ?? false,
      data: dataMap != null ? AddToCartData.fromJson(dataMap) : null,
    );
  }
}

class AddToCartData {
  final String sessionId;
  final String token;

  AddToCartData({required this.sessionId, required this.token});

  factory AddToCartData.fromJson(Map<String, dynamic> json) {
    return AddToCartData(
      sessionId: json['sessionId'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
