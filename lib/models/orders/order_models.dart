class MergedOrdersResponse {
  final bool success;
  final List<Order> items;

  MergedOrdersResponse({required this.success, required this.items});

  factory MergedOrdersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final itemsList = (data['orders'] ?? data['items']) as List? ?? [];
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
  final Address? shippingAddress;
  final Address? billingAddress;
  final Shipment? latestShipment;
  final List<Payment>? payments;

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
    this.shippingAddress,
    this.billingAddress,
    this.latestShipment,
    this.payments,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    return Order(
      id: json['id']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? json['orderNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paymentStatus: json['financial_status']?.toString() ?? json['paymentStatus']?.toString() ?? '',
      totalPrice: json['total_amount']?.toString() ?? json['totalPrice']?.toString() ?? '0.00',
      currency: json['currency']?.toString() ?? 'INR',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
      items: itemsList.map((item) => OrderItem.fromJson(item)).toList(),
      shippingAddress: json['shipping_address'] != null ? Address.fromJson(json['shipping_address']) : null,
      billingAddress: json['billing_address'] != null ? Address.fromJson(json['billing_address']) : null,
      latestShipment: json['latest_shipment'] != null ? Shipment.fromJson(json['latest_shipment']) : null,
      payments: json['payments'] != null ? (json['payments'] as List).map((p) => Payment.fromJson(p)).toList() : null,
    );
  }
}

class OrderItem {
  final String title;
  final int quantity;
  final String price;
  final String? imageUrl;
  final String productId;

  OrderItem({
    required this.title,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.productId = '',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      title: json['title']?.toString() ?? '',
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      price: json['price']?.toString() ?? '0.00',
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      productId: json['product_id']?.toString() ?? json['product']?['id']?.toString() ?? '',
    );
  }
}

class Address {
  final String firstName;
  final String lastName;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String phone;

  Address({
    required this.firstName,
    required this.lastName,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      addressLine1: json['address_line1']?.toString() ?? '',
      addressLine2: json['address_line2']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class Shipment {
  final String shipmentNumber;
  final String trackingNumber;
  final String? trackingUrl;
  final String? carrier;
  final String status;

  Shipment({
    required this.shipmentNumber,
    required this.trackingNumber,
    this.trackingUrl,
    this.carrier,
    required this.status,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      shipmentNumber: json['shipment_number']?.toString() ?? '',
      trackingNumber: json['tracking_number']?.toString() ?? '',
      trackingUrl: json['tracking_url']?.toString(),
      carrier: json['carrier']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }
}

class Payment {
  final String id;
  final String paymentMethod;
  final String status;

  Payment({
    required this.id,
    required this.paymentMethod,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
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
