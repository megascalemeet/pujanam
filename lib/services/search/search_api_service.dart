import 'package:pujanam/services/smart_search_service.dart';

import '../../models/search/search_response_model.dart';

/// Service responsible for performing search queries using the existing
/// `SmartSearchService`. It converts the raw JSON response into strongly typed
/// models defined in `search_response_model.dart`.
class SearchApiService {
  final SmartSearchService _smartSearchService = SmartSearchService();

  /// Searches for products (and optionally collections) matching the query.
  /// Returns a [SearchResponse] containing the parsed results.
  Future<Map<String, dynamic>> search(String query, {int limit = 10}) async {
    final raw = await _smartSearchService.searchProducts(query, limit: limit);
    return raw;
  }
}
