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

  /// Get optimized photo URLs for a class.
  Future<List<String>> getClassPhotos(String classId, {int limit = 1}) async {
    final cacheKey = 'class|$classId|$limit';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    final routeBuilders = [
      '/assets/files/class-gallery/$classId?optimize=true&limit=$limit',
      '/assets/files/class-photos/$classId?optimize=true&limit=$limit',
      '/assets/files/class-photo/$classId?optimize=true&limit=$limit',
      '/assets/files/classes/$classId/gallery?optimize=true&limit=$limit',
      '/assets/files/classes/$classId/photos?optimize=true&limit=$limit',
      '/assets/files/class/$classId/photos?optimize=true&limit=$limit',
      '/assets/files?entity=CLASS&entity_id=$classId&optimize=true&limit=$limit',
    ];

    final urls = await _tryRoutes(routeBuilders, _preferredClassRoute, (i) {
      _preferredClassRoute = i;
    });

    _cache[cacheKey] = urls;
    return urls;
  }

  /// Get optimized photo URLs for a category.
  Future<List<String>> getCategoryPhotos(String categoryId,
      {int limit = 1}) async {
    final cacheKey = 'category|$categoryId|$limit';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    final routeBuilders = [
      '/assets/files/category-gallery/$categoryId?optimize=true&limit=$limit',
      '/assets/files/category-photos/$categoryId?optimize=true&limit=$limit',
      '/assets/files/category-photo/$categoryId?optimize=true&limit=$limit',
      '/assets/files/categories/$categoryId/gallery?optimize=true&limit=$limit',
      '/assets/files/categories/$categoryId/photos?optimize=true&limit=$limit',
      '/assets/files/category/$categoryId/photos?optimize=true&limit=$limit',
      '/assets/files?entity=CATEGORY&entity_id=$categoryId&optimize=true&limit=$limit',
    ];

    final urls =
        await _tryRoutes(routeBuilders, _preferredCategoryRoute, (i) {
      _preferredCategoryRoute = i;
    });

    _cache[cacheKey] = urls;
    return urls;
  }

  /// Get optimized photo URLs for a branch.
  Future<List<String>> getBranchPhotos(String branchId,
      {int limit = 1}) async {
    final cacheKey = 'branch|$branchId|$limit';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    final routeBuilders = [
      '/assets/files/branch-gallery/$branchId?optimize=true&limit=$limit',
      '/assets/files/branch-photos/$branchId?optimize=true&limit=$limit',
      '/assets/files/branch-photo/$branchId?optimize=true&limit=$limit',
      '/assets/files/branches/$branchId/gallery?optimize=true&limit=$limit',
      '/assets/files/branches/$branchId/photos?optimize=true&limit=$limit',
      '/assets/files/branch/$branchId/photos?optimize=true&limit=$limit',
      '/assets/files?entity=BRANCH&entity_id=$branchId&optimize=true&limit=$limit',
    ];

    final urls = await _tryRoutes(routeBuilders, _preferredBranchRoute, (i) {
      _preferredBranchRoute = i;
    });

    _cache[cacheKey] = urls;
    return urls;
  }

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
