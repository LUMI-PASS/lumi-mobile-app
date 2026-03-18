import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_state.freezed.dart';

@freezed
class VerifyBuildable with _$VerifyBuildable {
  const factory VerifyBuildable(
      {@Default(false) bool loading,
      @Default(false) bool resetLoading,
      @Default(270) int timer,
      @Default(null) int? code,
      @Default(null) String? error}) = _VerifyBuildable;
}

@freezed
class VerifyListenable with _$VerifyListenable {
  const factory VerifyListenable(VerifyEffect effect) = _VerifyListenable;
}

enum VerifyEffect { success }
