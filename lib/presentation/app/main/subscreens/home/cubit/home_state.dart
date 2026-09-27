import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/promo/promo_campaign.dart';

part 'home_state.freezed.dart';

@freezed
class HomeBuildable with _$HomeBuildable {
  const factory HomeBuildable({
    @Default(false) bool isSelected,

    /// Starts TRUE, because a fresh home screen is always about to load.
    ///
    /// Home reads "no model and no classes" as a connection failure. On a
    /// default state that description also fits a screen that simply hasn't
    /// fetched yet — so a `false` here put the offline view on screen for every
    /// frame between the page mounting and the first response landing, and the
    /// user saw "no connection" on a perfectly good network.
    @Default(true) bool isLoading,
    @Default(false) bool success,
    HomeModel? homeModel,
    List<HomCategory>? categories,

    /// The packet ("аксия") on sale — the offer BOTH the carousel slide and the
    /// feed's ad card advertise. Held here so the screen makes one request for
    /// it however many slots show it, and so a purchase can refresh every slot
    /// at once. Null while it loads and when nothing is on sale, in which case
    /// neither slot renders.
    PromoCampaign? packet,
    // Location
    @Default(null) double? lat,
    @Default(null) double? lng,
    // Pagination for new classes
    @Default([]) List<HomClass> newClassesList,
    /// Real courses — the home 'Курсы' row. Kept separate from the class
    /// lists because a course is bought as a trial or as the whole course.
    @Default([]) List<HomClass> coursesList,
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
