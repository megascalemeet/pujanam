import 'dart:convert';

class AddReviewModel {
  final int productId;
  final String customerId;
  final int rating;
  final String description;
  final List<String> images;

  AddReviewModel({
    required this.productId,
    required this.customerId,
    required this.rating,
    required this.description,
    this.images = const [],
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'customer_id': customerId,
    'rating': rating,
    'description': description,
    'images': images,
  };

  String toEncodedJson() => json.encode(toJson());
}
