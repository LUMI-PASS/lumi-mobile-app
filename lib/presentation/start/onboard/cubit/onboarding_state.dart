import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
class OnboardingBuildable with _$OnboardingBuildable {
  const factory OnboardingBuildable({
    @Default(0) int index,
  }) = _OnboardingBuildable;
}

@freezed
class OnboardingListenable with _$OnboardingListenable {
  const factory OnboardingListenable({
    required OnboardEffect effect,
  }) = _OnboardingListenable;
}

enum OnboardEffect { home, login }
