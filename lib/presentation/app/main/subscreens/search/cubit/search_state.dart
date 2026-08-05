import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';

part 'search_state.freezed.dart';

/// No type chip picked — the screen's opening state everywhere except the two
/// home "see all" links, which arrive with the chip their row implies.
///
/// It is not a fourth endpoint: the cubit fans out to activities *and* courses
/// and interleaves them into the one grid, so "no filter" reads as everything
/// rather than as a silently pre-applied one.
const int kSearchTabAll = -1;

@freezed
class SearchBuildable with _$SearchBuildable {
  const factory SearchBuildable({
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool classesLoaded,
    @Default(false) bool branchesLoaded,
    @Default(kSearchTabAll) int activeTab,
    @Default('') String searchTerm,
    @Default([]) List<HomClass> classes,
    @Default([]) List<HomBranch> branches,
    @Default(1) int classesPage,
    @Default(1) int branchesPage,
    @Default(1) int classesTotalPages,
    @Default(1) int branchesTotalPages,
    @Default([]) List<HomCategory> categories,
    HomCategory? selectedCategory,
    FilterResult? filter,
    @Default(null) double? lat,
    @Default(null) double? lng,
  }) = _SearchBuildable;
}

@freezed
class SearchListenable with _$SearchListenable {
  const factory SearchListenable({
    required SearchEffect effect,
  }) = _SearchListenable;
}

enum SearchEffect { none }
