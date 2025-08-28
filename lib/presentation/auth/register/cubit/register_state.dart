import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

@freezed
class RegisterBuildable with _$RegisterBuildable {
  const factory RegisterBuildable({
    @Default(false) bool isSelected,
    @Default(false) bool isLoading,
    @Default(null) String? errorPhone,
  }) = _RegisterBuildable;
}

@freezed
class RegisterListenable with _$RegisterListenable {
  const factory RegisterListenable({
    required RegisterEffect effect,
  }) = _RegisterListenable;
}

enum RegisterEffect { main }
