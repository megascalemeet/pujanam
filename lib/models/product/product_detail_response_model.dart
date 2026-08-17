import 'product_response_model.dart';

class ProductDetailModel {
  final String id;
  final String storeId;
  final String title;
  final String description;
  final String imageUrl;
  final String productType;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String price;
  final String? compareAtPrice;
  final String? costPerItem;
  final String sku;
  final String? barcode;
  final bool trackQuantity;
  final int inventoryQuantity;
  final String weight;
  final String weightUnit;
  final String? hsCode;
  final String? originCountry;
  final String vendor;
  final List<String> tags;
  final String? seoTitle;
  final String? seoDescription;
  final String handle;
  final String? shopifyId;
  final String? taxRateId;
  final String? shippingPackageId;
  final String category;
  final bool chargeTax;
  final String hsnCode;
  final String packingWeight;
  final String packingWeightUnit;
  final List<dynamic> metafields;
  final double avgRating;
  final int totalReviews;
  final List<ReviewModel> reviews;
  final ProductPriceRangeModel? priceRange;
  final List<ProductVariantModel> variants;
  final List<ProductOptionModel> options;
  final List<ProductImageModel> images;

  ProductDetailModel({
    required this.id,
    required this.storeId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.productType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.price,
    this.compareAtPrice,
    this.costPerItem,
    required this.sku,
    this.barcode,
    required this.trackQuantity,
    required this.inventoryQuantity,
    required this.weight,
    required this.weightUnit,
    this.hsCode,
    this.originCountry,
    required this.vendor,
    required this.tags,
    this.seoTitle,
    this.seoDescription,
    required this.handle,
    this.shopifyId,
    this.taxRateId,
    this.shippingPackageId,
    required this.category,
    required this.chargeTax,
    required this.hsnCode,
    required this.packingWeight,
    required this.packingWeightUnit,
    required this.metafields,
    required this.avgRating,
    required this.totalReviews,
    required this.reviews,
    this.priceRange,
    required this.variants,
    required this.options,
    required this.images,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      id: json['id']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      productType: json['product_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      deletedAt: json['deleted_at']?.toString(),
      price: json['price']?.toString() ?? '0.00',
      compareAtPrice: json['compare_at_price']?.toString(),
      costPerItem: json['cost_per_item']?.toString(),
      sku: json['sku']?.toString() ?? '',
      barcode: json['barcode']?.toString(),
      trackQuantity: json['track_quantity'] == true,
      inventoryQuantity: int.tryParse(json['inventory_quantity']?.toString() ?? '0') ?? 0,
      weight: json['weight']?.toString() ?? '0.00',
      weightUnit: json['weight_unit']?.toString() ?? 'g',
      hsCode: json['hs_code']?.toString(),
      originCountry: json['origin_country']?.toString(),
      vendor: json['vendor']?.toString() ?? '',
      tags: (json['tags'] as List? ?? []).map((e) => e.toString()).toList(),
      seoTitle: json['seo_title']?.toString(),
      seoDescription: json['seo_description']?.toString(),
      handle: json['handle']?.toString() ?? '',
      shopifyId: json['shopify_id']?.toString(),
      taxRateId: json['tax_rate_id']?.toString(),
      shippingPackageId: json['shipping_package_id']?.toString(),
      category: json['category']?.toString() ?? '',
      chargeTax: json['charge_tax'] == true,
      hsnCode: json['hsn_code']?.toString() ?? '',
      packingWeight: json['packing_weight']?.toString() ?? '0.00',
      packingWeightUnit: json['packing_weight_unit']?.toString() ?? 'kg',
      metafields: json['metafields'] is List ? json['metafields'] : [],
      avgRating: double.tryParse(json['avg_rating']?.toString() ?? '0.0') ?? 0.0,
      totalReviews: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
      reviews: (json['reviews'] as List? ?? [])
          .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      priceRange: json['priceRange'] != null && json['priceRange'] is Map
          ? ProductPriceRangeModel.fromJson(Map<String, dynamic>.from(json['priceRange']))
          : null,
      variants: (json['variants'] as List? ?? [])
          .map((e) => ProductVariantModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      options: (json['options'] as List? ?? [])
          .map((e) => ProductOptionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      images: (json['images'] as List? ?? [])
          .map((e) => ProductImageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'product_type': productType,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'price': price,
      'compare_at_price': compareAtPrice,
      'cost_per_item': costPerItem,
      'sku': sku,
      'barcode': barcode,
      'track_quantity': trackQuantity,
      'inventory_quantity': inventoryQuantity,
      'weight': weight,
      'weight_unit': weightUnit,
      'hs_code': hsCode,
      'origin_country': originCountry,
      'vendor': vendor,
      'tags': tags,
      'seo_title': seoTitle,
      'seo_description': seoDescription,
      'handle': handle,
      'shopify_id': shopifyId,
      'tax_rate_id': taxRateId,
      'shipping_package_id': shippingPackageId,
      'category': category,
      'charge_tax': chargeTax,
      'hsn_code': hsnCode,
      'packing_weight': packingWeight,
      'packing_weight_unit': packingWeightUnit,
      'metafields': metafields,
      'avg_rating': avgRating,
      'total_reviews': totalReviews,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'priceRange': priceRange?.toJson(),
      'variants': variants.map((e) => e.toJson()).toList(),
      'options': options.map((e) => e.toJson()).toList(),
      'images': images.map((e) => e.toJson()).toList(),
    };
  }
}

class ProductDetailResponseModel {
  final bool success;
  final ProductDetailModel data;

  ProductDetailResponseModel({
    required this.success,
    required this.data,
  });

  factory ProductDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponseModel(
      success: json['success'] == true,
      data: ProductDetailModel.fromJson(json['data'] is Map ? Map<String, dynamic>.from(json['data']) : {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class ReviewModel {
  final String id;
  final int rating;
  final String title;
  final String description;
  final String customerName;
  final String reviewDate;
  final String createdAt;
  final List<String> images;

  ReviewModel({
    required this.id,
    required this.rating,
    required this.title,
    required this.description,
    required this.customerName,
    required this.reviewDate,
    required this.createdAt,
    required this.images,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      rating: int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? 'Anonymous',
      reviewDate: json['review_date']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      images: (json['images'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'title': title,
      'description': description,
      'customer_name': customerName,
      'review_date': reviewDate,
      'created_at': createdAt,
      'images': images,
    };
  }
}
