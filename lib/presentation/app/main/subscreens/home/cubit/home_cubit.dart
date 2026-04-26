import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends BaseCubit<HomeBuildable, HomeListenable> {
  HomeCubit(this._repo) : super(const HomeBuildable());
  final HomeRepository _repo;

  // Store location as instance fields so they're available immediately
  double? _lat;
  double? _lng;

  static const int _pageLimit = 10;

  /// Request location permission and fetch position, then load home feed.
  Future<void> initWithLocation() async {
    await _resolveLocation();
    await getHome();
  }

  Future<void> _resolveLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      // Check / request permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      // Try last known first (instant), fall back to current
      final position = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 10),
            ),
          );
      _lat = position.latitude;
      _lng = position.longitude;
      build((b) => b.copyWith(lat: _lat, lng: _lng));
    } catch (_) {
      // Location unavailable - proceed without it
    }
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
    if (buildable.isLoadingNewClasses || !buildable.hasMoreNewClasses) return;
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
    }
  }

  Future<void> loadMoreNearClasses() async {
    if (buildable.isLoadingNearClasses || !buildable.hasMoreNearClasses) return;
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
