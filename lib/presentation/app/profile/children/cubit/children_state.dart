import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';
import 'package:lumi_pass/data/api_model/schedule_class/schedule_class_model.dart';

part 'children_state.freezed.dart';

@freezed
class ChildrenBuildable with _$ChildrenBuildable {
  const factory ChildrenBuildable({
    @Default(false) bool isLoading,
    @Default(false) bool buttonLoading,
    @Default(0) int selectedIndex,
    @Default('Female') String selectedGender,
    @Default(null) DateTime? selectedBirthDate,
    List<ChildModel>? childrenList,
    @Default([]) List<TimeSlot> timeSlots,
    // Ticket booking selection state
    @Default(null) DateTime? selectedDate,
    @Default(null) String? selectedScheduleId,
    @Default(-1) int selectedTimeIndex,
  }) = _ChildrenBuildable;
}
@freezed
class ChildrenListenable with _$ChildrenListenable {
  const factory ChildrenListenable({
    required ChildrenEffect effect,
  }) = _ChildrenListenable;
}

enum ChildrenEffect { verify, reg }
