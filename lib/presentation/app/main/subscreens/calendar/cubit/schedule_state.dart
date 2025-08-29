import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';

part 'schedule_state.freezed.dart';

@freezed
class ScheduleBuildable with _$ScheduleBuildable {
  const factory ScheduleBuildable(
      {@Default(false) bool isSelected,
      @Default(false) bool isLoading,
      @Default(false) bool success,
      List<ScheduleItem>? homeModel}) = _ScheduleBuildable;
}

@freezed
class ScheduleListenable with _$ScheduleListenable {
  const factory ScheduleListenable({
    required ScheduleEffect effect,
  }) = _ScheduleListenable;
}

enum ScheduleEffect { verify, reg }
