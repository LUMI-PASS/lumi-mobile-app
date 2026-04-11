import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/api_model/attendance/attendance_model.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';

import 'attendance_state.dart';

@injectable
class AttendanceCubit
    extends BaseCubit<AttendanceBuildable, AttendanceListenable> {
  AttendanceCubit(this._repo) : super(const AttendanceBuildable());
  final HomeRepository _repo;

  Future<void> getChildren() {
    return callable(
      future: _repo.getChildren(),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      buildOnData: (List<ChildModel> data) {
        return buildable.copyWith(children: data);
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

  Future<void> getAttendanceHistory(String childId) {
    return callable(
      future: _repo.getChildAttendanceHistory(childId),
      buildOnStart: () => buildable.copyWith(isDetailLoading: true),
      buildOnData: (List<AttendanceRecord> data) {
        return buildable.copyWith(records: data);
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
      buildOnDone: () => buildable.copyWith(isDetailLoading: false),
    );
  }

  void selectChild(ChildModel child) {
    build((b) => b.copyWith(selectedChild: child));
  }
}
