import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

part 'home_state.freezed.dart';

@freezed
class HomeBuildable with _$HomeBuildable {
  const factory HomeBuildable({
    @Default(false) bool isSelected,
    @Default(false) bool isLoading,
    @Default(false) bool success,
    HomeModel? homeModel,
    List<HomCategory>? categories,
    // Pagination for new classes
    @Default([]) List<HomClass> newClassesList,
    @Default(2) int newClassesPage,
    @Default(false) bool isLoadingNewClasses,
    @Default(true) bool hasMoreNewClasses,
    // Pagination for near classes
    @Default([]) List<HomClass> nearClassesList,
    @Default(2) int nearClassesPage,
    @Default(false) bool isLoadingNearClasses,
    @Default(true) bool hasMoreNearClasses,
  }) = _HomeBuildable;
}

@freezed
class HomeListenable with _$HomeListenable {
  const factory HomeListenable({
    required HomeEffect effect,
  }) = _HomeListenable;
}

enum HomeEffect { verify, reg }
