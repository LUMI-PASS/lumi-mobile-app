import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'schedule_state.dart';

@injectable
class ScheduleCubit extends BaseCubit<ScheduleBuildable, ScheduleListenable> {
  ScheduleCubit(this._repo) : super(const ScheduleBuildable());
  final HomeRepository _repo;

  Future<void> getSchedule() {
    return callable(
      future: _repo.getScheduleList(),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      buildOnData: (data) {
        // Filter out items where all related bookings are CANCELLED
        final filtered = data.where((item) {
          final bookings = item.relatedBookings ?? [];
          if (bookings.isEmpty) return true;
          return bookings.any((b) =>
              b.bookingStatus?.toUpperCase() != 'CANCELLED');
        }).toList();
        return buildable.copyWith(homeModel: filtered);
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
      },
      buildOnDone: () => buildable.copyWith(isLoading: false),
    );
  }

  /// Refresh without showing loading spinner (for tab switches)
  Future<void> refreshSilently() async {
    try {
      final data = await _repo.getScheduleList();
      final filtered = data.where((item) {
        final bookings = item.relatedBookings ?? [];
        if (bookings.isEmpty) return true;
        return bookings.any((b) =>
            b.bookingStatus?.toUpperCase() != 'CANCELLED');
      }).toList();
      build((b) => b.copyWith(homeModel: filtered));
    } catch (_) {}
  }

  void changePhoneState(bool isMatched) {
    build((buildable) => buildable.copyWith(isSelected: isMatched));
  }
}
