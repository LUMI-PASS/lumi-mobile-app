import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';

part 'schedule_state.freezed.dart';

@freezed
class ScheduleBuildable with _$ScheduleBuildable {
  const factory ScheduleBuildable({
    @Default(false) bool isLoading,
    @Default([]) List<UserOrder> orders,
  }) = _ScheduleBuildable;
}

@freezed
class ScheduleListenable with _$ScheduleListenable {
  const factory ScheduleListenable({
    required ScheduleEffect effect,
  }) = _ScheduleListenable;
}

enum ScheduleEffect { verify, reg }
