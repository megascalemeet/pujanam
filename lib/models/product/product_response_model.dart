class ProductResponseModel {
  final bool success;
  final List<ProductModel> data;
  final ProductPaginationModel pagination;

  ProductResponseModel({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductResponseModel(
      success: json['success'] == true,
      data: (json['data'] as List? ?? [])
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      pagination: ProductPaginationModel.fromJson(json['pagination'] is Map ? Map<String, dynamic>.from(json['pagination']) : {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class ProductPriceRangeModel {
  final ProductPriceModel minVariantPrice;
  final ProductPriceModel maxVariantPrice;

  ProductPriceRangeModel({
    required this.minVariantPrice,
    required this.maxVariantPrice,
  });

  factory ProductPriceRangeModel.fromJson(Map<String, dynamic> json) {
    return ProductPriceRangeModel(
      minVariantPrice: ProductPriceModel.fromJson(json['minVariantPrice'] is Map ? Map<String, dynamic>.from(json['minVariantPrice']) : {}),
      maxVariantPrice: ProductPriceModel.fromJson(json['maxVariantPrice'] is Map ? Map<String, dynamic>.from(json['maxVariantPrice']) : {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minVariantPrice': minVariantPrice.toJson(),
      'maxVariantPrice': maxVariantPrice.toJson(),
    };
  }
}

class ProductModel {
  final String id;
  final String title;
  final String handle;
  final String description;
  final String status;
  final List<dynamic> metafields;
  final List<int> variantIds;
  final String imageUrl;
  final bool availableForSale;
  final ProductPriceRangeModel? priceRange;
  final ProductPriceModel? compareAtPrice;
  final List<ProductImageModel> images;
  final List<String> tags;
  final double avgRating;
  final int totalReviews;
  final int inventoryQuantity;
  final List<ProductVariantModel> variants;
  final List<ProductOptionModel> options;
  final String createdAt;
  final String updatedAt;

  ProductModel({
    required this.id,
    required this.title,
    required this.handle,
    required this.description,
    required this.status,
    required this.metafields,
    required this.variantIds,
    required this.imageUrl,
    required this.availableForSale,
    this.priceRange,
    this.compareAtPrice,
    required this.images,
    required this.tags,
    required this.avgRating,
    required this.totalReviews,
    required this.inventoryQuantity,
    required this.variants,
    required this.options,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      handle: json['handle']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      metafields: json['metafields'] is List ? json['metafields'] : [],
      variantIds: (json['variant_ids'] as List? ?? []).map((e) => int.tryParse(e.toString()) ?? 0).toList(),
      imageUrl: json['image_url']?.toString() ?? '',
      availableForSale: json['availableForSale'] == true,
      priceRange: json['priceRange'] != null && json['priceRange'] is Map
          ? ProductPriceRangeModel.fromJson(Map<String, dynamic>.from(json['priceRange']))
          : null,
      compareAtPrice: json['compareAtPrice'] != null && json['compareAtPrice'] is Map
          ? ProductPriceModel.fromJson(Map<String, dynamic>.from(json['compareAtPrice']))
          : null,
      images: (json['images'] as List? ?? [])
          .map((e) => ProductImageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      tags: (json['tags'] as List? ?? []).map((e) => e.toString()).toList(),
      avgRating: double.tryParse(json['avg_rating']?.toString() ?? '0.0') ?? 0.0,
      totalReviews: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
      inventoryQuantity: int.tryParse(json['inventory_quantity']?.toString() ?? '0') ?? 0,
      variants: (json['variants'] as List? ?? [])
          .map((e) => ProductVariantModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      options: (json['options'] as List? ?? [])
          .map((e) => ProductOptionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'handle': handle,
      'description': description,
      'status': status,
      'metafields': metafields,
      'variant_ids': variantIds,
      'image_url': imageUrl,
      'availableForSale': availableForSale,
      'priceRange': priceRange?.toJson(),
      'compareAtPrice': compareAtPrice?.toJson(),
      'images': images.map((e) => e.toJson()).toList(),
      'tags': tags,
      'avg_rating': avgRating,
      'total_reviews': totalReviews,
      'inventory_quantity': inventoryQuantity,
      'variants': variants.map((e) => e.toJson()).toList(),
      'options': options.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ProductOptionModel {
  final String name;
  final List<String> values;

  ProductOptionModel({
    required this.name,
    required this.values,
  });

  factory ProductOptionModel.fromJson(Map<String, dynamic> json) {
    return ProductOptionModel(
      name: json['name']?.toString() ?? '',
      values: (json['values'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'values': values,
    };
  }
}

class ProductImageModel {
  final String url;

  ProductImageModel({
    required this.url,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }
}

class ProductVariantModel {
  final int id;
  final String title;
  final bool availableForSale;
  final String? sku;
  final ProductPriceModel price;
  final ProductPriceModel? compareAtPrice;
  final List<ProductSelectedOptionModel> selectedOptions;
  final ProductImageModel? image;
  final double weight;
  final String weightUnit;
  final int inventoryQuantity;

  ProductVariantModel({
    required this.id,
    required this.title,
    required this.availableForSale,
    this.sku,
    required this.price,
    this.compareAtPrice,
    required this.selectedOptions,
    this.image,
    required this.weight,
    required this.weightUnit,
    required this.inventoryQuantity,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      availableForSale: json['availableForSale'] == true,
      sku: json['sku']?.toString(),
      price: ProductPriceModel.fromJson(json['price'] is Map ? Map<String, dynamic>.from(json['price']) : {}),
      compareAtPrice: json['compareAtPrice'] != null && json['compareAtPrice'] is Map
          ? ProductPriceModel.fromJson(Map<String, dynamic>.from(json['compareAtPrice']))
          : null,
      selectedOptions: (json['selectedOptions'] as List? ?? [])
          .map((e) => ProductSelectedOptionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      image: json['image'] != null && json['image'] is Map
          ? ProductImageModel.fromJson(Map<String, dynamic>.from(json['image']))
          : null,
      weight: double.tryParse(json['weight']?.toString() ?? '0.0') ?? 0.0,
      weightUnit: json['weightUnit']?.toString() ?? 'KG',
      inventoryQuantity: int.tryParse(json['inventoryQuantity']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'availableForSale': availableForSale,
      'sku': sku,
      'price': price.toJson(),
      'compareAtPrice': compareAtPrice?.toJson(),
      'selectedOptions': selectedOptions.map((e) => e.toJson()).toList(),
      'image': image?.toJson(),
      'weight': weight,
      'weightUnit': weightUnit,
      'inventoryQuantity': inventoryQuantity,
    };
  }
}

class ProductSelectedOptionModel {
  final String name;
  final String value;

  ProductSelectedOptionModel({
    required this.name,
    required this.value,
  });

  factory ProductSelectedOptionModel.fromJson(Map<String, dynamic> json) {
    return ProductSelectedOptionModel(
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

class ProductPriceModel {
  final String amount;
  final String currencyCode;

  ProductPriceModel({
    required this.amount,
    required this.currencyCode,
  });

  factory ProductPriceModel.fromJson(Map<String, dynamic> json) {
    return ProductPriceModel(
      amount: json['amount']?.toString() ?? '0.0',
      currencyCode: json['currencyCode']?.toString() ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currencyCode': currencyCode,
    };
  }
}

class ProductPaginationModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  ProductPaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory ProductPaginationModel.fromJson(Map<String, dynamic> json) {
    return ProductPaginationModel(
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      page: int.tryParse(json['page']?.toString() ?? '1') ?? 1,
      limit: int.tryParse(json['limit']?.toString() ?? '10') ?? 10,
      totalPages: int.tryParse(json['totalPages']?.toString() ?? '0') ?? 0,
      hasNextPage: json['hasNextPage'] == true,
      hasPrevPage: json['hasPrevPage'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }
}
