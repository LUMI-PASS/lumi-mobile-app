import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

class ShortsFeed {
  static List<HomClass>? pendingClasses;
  static int pendingIndex = 0;

  static bool get hasPending =>
      pendingClasses != null && pendingClasses!.isNotEmpty;

  static void set(List<HomClass> classes, int index) {
    pendingClasses = classes;
    pendingIndex = index.clamp(0, classes.length - 1);
  }

  static void clear() {
    pendingClasses = null;
    pendingIndex = 0;
  }

  /// The last default feed, kept across tab visits.
  ///
  /// The Shorts tab is lazy-built by AutoTabsScaffold, so its `initState` —
  /// and the discovery request in it — ran on every visit. That round trip sat
  /// in front of the first player being created at all, i.e. squarely inside
  /// the time the user spends staring at a blank screen. Re-entering the tab
  /// within the TTL now starts playing immediately.
  /// Everything paged in so far, not just the first page — coming back to the
  /// tab should not make the user swipe through the same 30 again to reach
  /// where they were.
  static List<HomClass>? _cached;
  static DateTime? _cachedAt;
  static int _cachedNextPage = 1;
  static bool _cachedHasMore = true;

  static const Duration _cacheTtl = Duration(minutes: 10);

  static List<HomClass>? get cached {
    final at = _cachedAt;
    if (_cached == null || at == null) return null;
    if (DateTime.now().difference(at) > _cacheTtl) {
      _cached = null;
      _cachedAt = null;
      return null;
    }
    return _cached;
  }

  /// The discovery page to ask for next, and whether there is one.
  static int get cachedNextPage => _cachedNextPage;
  static bool get cachedHasMore => _cachedHasMore;

  static void cache(
    List<HomClass> classes, {
    required int nextPage,
    required bool hasMore,
  }) {
    _cached = classes;
    _cachedAt = DateTime.now();
    _cachedNextPage = nextPage;
    _cachedHasMore = hasMore;
  }
}
