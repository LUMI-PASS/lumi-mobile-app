import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';

part 'children_state.freezed.dart';

@freezed
class ChildrenBuildable with _$ChildrenBuildable {
  const factory ChildrenBuildable(
      {@Default(false) bool isLoading,
      @Default(0) int selectedIndex,
      List<ChildModel>? childrenList}) = _ChildrenBuildable;
}

@freezed
class ChildrenListenable with _$ChildrenListenable {
  const factory ChildrenListenable({
    required ChildrenEffect effect,
  }) = _ChildrenListenable;
}

enum ChildrenEffect { verify, reg }
