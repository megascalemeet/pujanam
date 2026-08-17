class CategoryProductModel {
  final String id;
  final String title;
  final String handle;
  final String description;
  final String status;
  final double price;
  final double compareAtPrice;
  final String? imageUrl;
  final bool availableForSale;
  final int inventoryQuantity;
  final double avgRating;
  final int totalReviews;
  final List<dynamic> variants;
  final List<dynamic> images;
  final List<dynamic> metafields;
  final Map<String, dynamic>? priceRange;
  final Map<String, dynamic>? compareAtPriceMap;

  CategoryProductModel({
    required this.id,
    required this.title,
    required this.handle,
    required this.description,
    required this.status,
    required this.price,
    required this.compareAtPrice,
    this.imageUrl,
    required this.availableForSale,
    required this.inventoryQuantity,
    required this.avgRating,
    required this.totalReviews,
    required this.variants,
    required this.images,
    required this.metafields,
    this.priceRange,
    this.compareAtPriceMap,
  });

  factory CategoryProductModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return CategoryProductModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      handle: json['handle']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      price: parseDouble(json['price']),
      compareAtPrice: parseDouble(json['compare_at_price']),
      imageUrl: json['image_url']?.toString(),
      availableForSale: json['availableForSale'] ?? false,
      inventoryQuantity: (json['inventory_quantity'] as num?)?.toInt() ?? 0,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      variants: json['variants'] is List ? json['variants'] : [],
      images: json['images'] is List ? json['images'] : [],
      metafields: json['metafields'] is List ? json['metafields'] : [],
      priceRange: json['priceRange'] is Map ? json['priceRange'] : null,
      compareAtPriceMap: json['compareAtPrice'] is Map
          ? json['compareAtPrice']
          : null,
    );
  }
}
