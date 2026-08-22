import 'dart:convert';

/// Model representing a product item returned from the search API.
/// This is intentionally lightweight and independent of the existing
/// `ProductModel` to avoid coupling with other parts of the codebase.
class SearchProduct {
  final String id;
  final String title;
  final String handle;
  final String? imageUrl;
  final double price;
  final double? compareAtPrice;
  final double rating;
  final int reviewCount;

  SearchProduct({
    required this.id,
    required this.title,
    required this.handle,
    this.imageUrl,
    required this.price,
    this.compareAtPrice,
    required this.rating,
    required this.reviewCount,
  });

  /// Creates a [SearchProduct] from a generic JSON map returned by the
  /// `SmartSearchService`. The shape mirrors what `ProductCard` expects, so
  /// the UI can reuse the existing widget without modification.
  factory SearchProduct.fromJson(Map<String, dynamic> json) {
    double _extractPrice(dynamic priceNode) {
      if (priceNode == null) return 0.0;
      if (priceNode is Map) {
        // Handle priceRange structure or direct amount map
        return double.tryParse(
              (priceNode['amount'] ?? priceNode['minVariantPrice']?['amount'])
                      ?.toString() ??
                  '0.0',
            ) ??
            0.0;
      }
      return double.tryParse(priceNode.toString()) ?? 0.0;
    }

    String? _extractImage(Map<String, dynamic> product) {
      if (product['image_url'] != null) {
        return product['image_url'].toString();
      }
      if (product['images'] is Map &&
          product['images']['edges'] is List &&
          (product['images']['edges'] as List).isNotEmpty) {
        final firstEdge = (product['images']['edges'] as List).first;
        if (firstEdge is Map && firstEdge['node'] is Map) {
          return firstEdge['node']['url']?.toString();
        }
      }
      if (product['images'] is List && (product['images'] as List).isNotEmpty) {
        final img = (product['images'] as List).first;
        if (img is Map) {
          return img['url']?.toString() ?? img['src']?.toString();
        }
      }
      if (product['media'] is List && (product['media'] as List).isNotEmpty) {
        final img = (product['media'] as List).first;
        if (img is Map) {
          return img['previewSrc']?.toString() ?? img['src']?.toString();
        }
      }
      return null;
    }

    final variants = json['variants'] as List<dynamic>? ?? [];
    final firstVariant = variants.isNotEmpty ? variants.first : null;

    final price = _extractPrice(
      json['priceRange'] ?? firstVariant?['price'] ?? json['price'],
    );
    final comparePrice = _extractPrice(
      json['compareAtPrice'] ?? firstVariant?['compareAtPrice'],
    );

    return SearchProduct(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      handle: json['handle']?.toString() ?? '',
      imageUrl: _extractImage(json),
      price: price,
      compareAtPrice: comparePrice == 0.0 ? null : comparePrice,
      rating: double.tryParse(json['avg_rating']?.toString() ?? '0.0') ?? 0.0,
      reviewCount: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
    );
  }

  /// Convert back to a map compatible with `ProductCard`'s expectations.
  Map<String, dynamic> toProductCardMap() {
    return {
      'id': id,
      'title': title,
      'handle': handle,
      'variants': [
        {
          'price': price.toString(),
          if (compareAtPrice != null)
            'compareAtPrice': compareAtPrice.toString(),
        },
      ],
      if (imageUrl != null)
        'media': [
          {'previewSrc': imageUrl},
        ],
      'metafields': {
        'reviews.rating': jsonEncode({'value': rating.toString()}),
        'reviews.rating_count': reviewCount.toString(),
      },
    };
  }
}
