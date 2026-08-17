class CategoryModel {
  final String id;
  final String storeId;
  final String title;
  final String handle;
  final String description;
  final String? imageUrl;
  final bool isActive;
  final bool isAutomated;
  final String sortOrder;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? taxRateId;
  final bool isDisplay;
  final String productCount;
  final List<dynamic> metafields;

  CategoryModel({
    required this.id,
    required this.storeId,
    required this.title,
    required this.handle,
    required this.description,
    this.imageUrl,
    required this.isActive,
    required this.isAutomated,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.taxRateId,
    required this.isDisplay,
    required this.productCount,
    required this.metafields,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      handle: json['handle']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? false,
      isAutomated: json['is_automated'] ?? false,
      sortOrder: json['sort_order']?.toString() ?? 'manual',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString(),
      taxRateId: json['tax_rate_id']?.toString(),
      isDisplay: json['is_display'] ?? false,
      productCount: json['product_count']?.toString() ?? '0',
      metafields: json['metafields'] is List ? json['metafields'] : [],
    );
  }
}
