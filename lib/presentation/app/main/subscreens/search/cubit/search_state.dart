import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';

part 'search_state.freezed.dart';

/// The results grid: activities and courses together.
///
/// There is no separate courses tab. A course and a class answer the same
/// question — "what is on for my child" — so they share one list, and narrowing
/// to one or the other is a FILTER over that list (`FilterResult.kind`) rather
/// than a place you navigate to. The two tabs left are things you genuinely
/// cannot show in one grid: sessions, and the centres that run them.
const int kSearchTabClasses = 0;

/// Centres. Kept at 1 because the map screen opens straight onto it.
const int kSearchTabBranches = 1;

@freezed
class SearchBuildable with _$SearchBuildable {
  const factory SearchBuildable({
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool classesLoaded,
    @Default(false) bool branchesLoaded,
    @Default(kSearchTabClasses) int activeTab,
    @Default('') String searchTerm,
    @Default([]) List<HomClass> classes,
    @Default([]) List<HomBranch> branches,
    @Default(1) int classesPage,
    @Default(1) int branchesPage,
    @Default(1) int classesTotalPages,
    @Default(1) int branchesTotalPages,
    @Default([]) List<HomCategory> categories,

    /// Activities the user last opened from this screen, newest first.
    /// Persisted — see `RecentSearchStore`.
    @Default([]) List<HomClass> recentClasses,

    /// True while the screen is showing [recentClasses] instead of results.
    ///
    /// The state search opens in when it was reached from Home's search field:
    /// the user asked to type, not to be handed a page of everything. Anything
    /// that names what they want — a character typed, a category, a filter, a
    /// tab — turns this off and runs the real query.
    @Default(false) bool showRecents,

    /// The category filter — multi-select: an empty list means "all
    /// categories". Kept as the resolved objects (not bare ids) so chips and
    /// the picker sheet have a title to show without a second lookup.
    @Default([]) List<HomCategory> selectedCategories,
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
