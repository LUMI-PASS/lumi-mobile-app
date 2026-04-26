import 'package:dio/dio.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/di/injection.dart';

/// Mirrors the webapp's multi-endpoint photo resolution strategy.
/// Tries multiple API routes to find photos for classes/categories,
/// caches successful route indices and results.
class PhotoService {
  PhotoService._();
  static final PhotoService instance = PhotoService._();

  final Dio _dio = getIt<Dio>();
  final Map<String, List<String>> _cache = {};
  int? _preferredClassRoute;
  int? _preferredCategoryRoute;

  static String getImageUrl(String entityId) {
    return '${Constants.assetsUrl}$entityId';
  }

  // Backend now returns image URLs inline in list/detail responses.
  // These probe methods are kept as no-ops so existing call sites compile.
  Future<List<String>> getClassPhotos(String classId, {int limit = 1}) async =>
      const [];

  Future<List<String>> getCategoryPhotos(String categoryId,
          {int limit = 1}) async =>
      const [];

  Future<List<String>> getBranchPhotos(String branchId,
          {int limit = 1}) async =>
      const [];

  int? _preferredBranchRoute;

  Future<List<String>> _tryRoutes(
    List<String> routes,
    int? preferredIndex,
    void Function(int) onPreferred,
  ) async {
    // Build probe order: preferred first, then rest
    final order = <int>[];
    if (preferredIndex != null) {
      order.add(preferredIndex);
      for (int i = 0; i < routes.length; i++) {
        if (i != preferredIndex) order.add(i);
      }
    } else {
      for (int i = 0; i < routes.length; i++) {
        order.add(i);
      }
    }

    for (final idx in order) {
      try {
        final response = await _dio.get(routes[idx]);
        final urls = _extractUrls(response.data);
        if (urls.isNotEmpty) {
          onPreferred(idx);
          return urls;
        }
      } catch (_) {
        // Try next endpoint
      }
    }

    return [];
  }

  List<String> _extractUrls(dynamic data) {
    final results = <String>[];

    if (data is List) {
      for (final item in data) {
        final url = _extractSingleUrl(item);
        if (url != null) results.add(url);
      }
    } else if (data is Map) {
      // Could be { data: [...] } or { url: "..." }
      if (data.containsKey('data') && data['data'] is List) {
        for (final item in data['data']) {
          final url = _extractSingleUrl(item);
          if (url != null) results.add(url);
        }
      } else {
        final url = _extractSingleUrl(data);
        if (url != null) results.add(url);
      }
    }

    return results;
  }

  String? _extractSingleUrl(dynamic item) {
    if (item is String && item.isNotEmpty) return _toFullUrl(item);
    if (item is Map) {
      final raw = item['url'] ?? item['file_url'] ?? item['src'] ?? item['id'];
      if (raw is String && raw.isNotEmpty) return _toFullUrl(raw);
    }
    return null;
  }

  String _toFullUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    // UUID-like IDs → assetsUrl
    return '${Constants.assetsUrl}$trimmed';
  }

  void clearCache() {
    _cache.clear();
  }
}
