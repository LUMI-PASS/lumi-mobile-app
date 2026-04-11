import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/eligibility/eligibility_model.dart';
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
    // Trial summary
    @Default(null) ParentTrialSummary? trialSummary,
    // Parent location (for add child form)
    @Default('Tashkent') String parentCity,
    @Default('') String parentDistrict,
    // Add child stepper
    @Default(0) int currentStep,
    @Default(null) String? newChildId,
    // Ticket booking selection state
    @Default(null) DateTime? selectedDate,
    @Default(null) String? selectedScheduleId,
    @Default(-1) int selectedTimeIndex,
    // Eligibility & booking state
    @Default(null) ClassEligibilityData? eligibilityData,
    @Default(false) bool eligibilityLoading,
    @Default(false) bool bookingLoading,
    @Default(null) String? selectedChildId,
  }) = _ChildrenBuildable;
}

@freezed
class ChildrenListenable with _$ChildrenListenable {
  const factory ChildrenListenable({
    required ChildrenEffect effect,
    String? bookingId,
  }) = _ChildrenListenable;
}

enum ChildrenEffect {
  verify,
  reg,
  bookingSuccess,
  eligibilityLoaded,
  eligibilityError,
  childCreated,
  photoUploaded,
  photoUploadError,
}
