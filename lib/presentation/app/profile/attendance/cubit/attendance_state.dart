import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/attendance/attendance_model.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';

part 'attendance_state.freezed.dart';

@freezed
class AttendanceBuildable with _$AttendanceBuildable {
  const factory AttendanceBuildable({
    @Default(false) bool isLoading,
    @Default(false) bool isDetailLoading,
    List<ChildModel>? children,
    ChildModel? selectedChild,
    @Default([]) List<AttendanceRecord> records,
  }) = _AttendanceBuildable;
}

@freezed
class AttendanceListenable with _$AttendanceListenable {
  const factory AttendanceListenable({
    required AttendanceEffect effect,
  }) = _AttendanceListenable;
}

enum AttendanceEffect {
  none,
}
