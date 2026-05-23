import 'dart:async';

import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/common/utils/display_name_notifier.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends BaseCubit<HomeBuildable, HomeListenable> {
  HomeCubit(this._repo, this._storage) : super(const HomeBuildable());
  final HomeRepository _repo;
  final Storage _storage;

  String _lastLang = '';
  // Track premium/coupon state so we can detect changes on focus regain.
  bool _lastKnownHasPremium = false;
  int _lastKnownCouponPct = 0;

  // Store location as instance fields so they're available immediately
  double? _lat;
  double? _lng;

  // Sync guards to prevent re-entrant load-more calls
  bool _newLoadLock = false;
  bool _nearLoadLock = false;

  static const int _pageLimit = 10;

  Future<void> initWithLocation() async {
    _lastLang = currentLang;
    _lastKnownHasPremium = _storage.hasPremium() == true;
    _lastKnownCouponPct = _storage.planDiscountPercentage() ?? 0;
    // Load home feed and the full category list concurrently.
    await Future.wait([getHome(), _loadAllCategories()]);
  }

  /// Fetches the complete category list from the unlimited /categories endpoint
  /// and stores it in state. Called concurrently with [getHome] so categories
  /// are not limited to the 10-item page that the home feed returns.
  Future<void> _loadAllCategories() async {
    try {
      final cats = await _repo.getAllCategories();
      if (cats.isNotEmpty) build((b) => b.copyWith(categories: cats));
    } catch (_) {}
  }

  Future<void> refreshIfLanguageChanged() async {
    final lang = currentLang;
    if (_lastLang == lang) return;
    _lastLang = lang;
    await refreshSilently();
  }

  /// Called when the home tab regains focus. Silently refreshes when language
  /// OR coupon/premium status has changed since the last load, so discount
  /// badges and prices update immediately after a plan purchase.
  Future<void> refreshOnFocusGained() async {
    final lang = currentLang;
    final hasPremium = _storage.hasPremium() == true;
    final couponPct = _storage.planDiscountPercentage() ?? 0;

    final langChanged = _lastLang != lang;
    final couponChanged =
        _lastKnownHasPremium != hasPremium || _lastKnownCouponPct != couponPct;

    if (!langChanged && !couponChanged) return;

    _lastLang = lang;
    _lastKnownHasPremium = hasPremium;
    _lastKnownCouponPct = couponPct;

    await refreshSilently();
  }

  Future<void> getHome() async {
    return callable(
      future: _repo.getHome(
        newClassesPage: 1,
        newClassesLimit: _pageLimit,
        categoryPage: 1,
        categoryLimit: _pageLimit,
        nearClassPage: 1,
        nearClassLimit: _pageLimit,
        lat: _lat,
        lng: _lng,
      ),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      buildOnData: (data) {
        final newClasses = data.data?.newClasses?.data ?? [];
        final nearClasses = data.data?.nearClasses?.data ?? [];
        final firstName = data.data?.forUser?.firstName;
        if (firstName != null && firstName.isNotEmpty) {
          _storage.parentName.set(firstName);
          displayNameNotifier.value = firstName;
        }
        return buildable.copyWith(
          homeModel: data,
          newClassesList: newClasses,
          nearClassesList: nearClasses,
          newClassesPage: 2,
          nearClassesPage: 2,
          hasMoreNewClasses: newClasses.length >= _pageLimit,
          hasMoreNearClasses: nearClasses.length >= _pageLimit,
        );
      },
      onErrorData: (error) {
        if (error is DioException) {
          if (error.response?.statusCode == 500 ||
              error.response?.statusCode == 502) {
            display.error(Strings.serverErrorTryLater);
          } else if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            display.error(Strings.connectionError);
          }
        }
        display.error(error);
      },
      buildOnDone: () => buildable.copyWith(isLoading: false),
    );
  }

  /// Silent refresh (used on tab focus) — no shimmer.
  Future<void> refreshSilently() async {
    // Reload categories in parallel so they stay up-to-date on language change.
    unawaited(_loadAllCategories());
    try {
      final data = await _repo.getHome(
        newClassesPage: 1,
        newClassesLimit: _pageLimit,
        categoryPage: 1,
        categoryLimit: _pageLimit,
        nearClassPage: 1,
        nearClassLimit: _pageLimit,
        lat: _lat,
        lng: _lng,
      );
      final newClasses = data.data?.newClasses?.data ?? [];
      final nearClasses = data.data?.nearClasses?.data ?? [];
      final silentName = data.data?.forUser?.firstName;
      if (silentName != null && silentName.isNotEmpty) {
        _storage.parentName.set(silentName);
        displayNameNotifier.value = silentName;
      }
      build((b) => b.copyWith(
            homeModel: data,
            newClassesList: newClasses,
            nearClassesList: nearClasses,
            newClassesPage: 2,
            nearClassesPage: 2,
            hasMoreNewClasses: newClasses.length >= _pageLimit,
            hasMoreNearClasses: nearClasses.length >= _pageLimit,
          ));
    } catch (_) {}
  }

  Future<void> loadMoreNewClasses() async {
    if (_newLoadLock || buildable.isLoadingNewClasses || !buildable.hasMoreNewClasses) return;
    _newLoadLock = true;
    build((b) => b.copyWith(isLoadingNewClasses: true));

    try {
      final data = await _repo.getHome(
        newClassesPage: buildable.newClassesPage,
        newClassesLimit: _pageLimit,
        lat: _lat,
        lng: _lng,
      );
      final incoming = data.data?.newClasses?.data ?? [];
      final existingIds = buildable.newClassesList.map((c) => c.id).toSet();
      final unique =
          incoming.where((c) => !existingIds.contains(c.id)).toList();

      build((b) => b.copyWith(
            newClassesList: [...b.newClassesList, ...unique],
            newClassesPage: b.newClassesPage + 1,
            isLoadingNewClasses: false,
            hasMoreNewClasses: incoming.length >= _pageLimit,
          ));
    } catch (_) {
      build((b) => b.copyWith(isLoadingNewClasses: false));
    } finally {
      _newLoadLock = false;
    }
  }

  Future<void> loadMoreNearClasses() async {
    if (_nearLoadLock || buildable.isLoadingNearClasses || !buildable.hasMoreNearClasses) return;
    _nearLoadLock = true;
    build((b) => b.copyWith(isLoadingNearClasses: true));

    try {
      final data = await _repo.getHome(
        nearClassPage: buildable.nearClassesPage,
        nearClassLimit: _pageLimit,
        lat: _lat,
        lng: _lng,
      );
      final incoming = data.data?.nearClasses?.data ?? [];
      final existingIds = buildable.nearClassesList.map((c) => c.id).toSet();
      final unique =
          incoming.where((c) => !existingIds.contains(c.id)).toList();

      build((b) => b.copyWith(
            nearClassesList: [...b.nearClassesList, ...unique],
            nearClassesPage: b.nearClassesPage + 1,
            isLoadingNearClasses: false,
            hasMoreNearClasses: incoming.length >= _pageLimit,
          ));
    } catch (_) {
      build((b) => b.copyWith(isLoadingNearClasses: false));
    } finally {
      _nearLoadLock = false;
    }
  }

  Future<void> getCategories() async {
    return callable(
      future: _repo.getAllCategories(),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      buildOnData: (data) {
        return buildable.copyWith(categories: data);
      },
      onErrorData: (error) {
        if (error is DioException) {
          if (error.response?.statusCode == 500 ||
              error.response?.statusCode == 502) {
            display.error(Strings.serverErrorTryLater);
          } else if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            display.error(Strings.connectionError);
          }
        }
        display.error(error);
      },
      buildOnDone: () => buildable.copyWith(isLoading: false),
    );
  }

  void changePhoneState(bool isMatched) {
    build((buildable) => buildable.copyWith(isSelected: isMatched));
  }
}
