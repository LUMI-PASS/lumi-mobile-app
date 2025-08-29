import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
class LoginBuildable with _$LoginBuildable {
  const factory LoginBuildable({
    @Default(false) bool isSelected,
    @Default(false) bool isLoading,
    @Default(false) bool success,
    @Default(null) String? errorPhone,
    @Default(null) String? errorPassword,
  }) = _LoginBuildable;
}

@freezed
class LoginListenable with _$LoginListenable {
  const factory LoginListenable({
    required LoginEffect effect,
  }) = _LoginListenable;
}

enum LoginEffect {
  verify, reg
}
