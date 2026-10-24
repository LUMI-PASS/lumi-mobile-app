import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/display_name_notifier.dart';
import 'package:lumi_pass/common/utils/home_scroll_to_top.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/new_coin_price.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/unclaimed_centre/unclaimed_centre.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:lumi_pass/presentation/app/cubit/app_state.dart';
import 'package:lumi_pass/presentation/app/main/main_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/home_feed_layout.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_feed_inserts.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/catgory_item_widget.dart';
import 'package:lumi_pass/domain/repo/banners/banner_click_reporter.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_banners.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_class_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_common.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_header.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_interests_strip.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_skeletons.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_unclaimed_shelf.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/today_bookings.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/shorts/shorts_feed.dart';
import 'package:lumi_pass/presentation/auth/interests/parent_interests_page.dart';

// Tab index of the Shorts tab inside the main AutoTabsScaffold.
const int _kShortsTabIndex = 2;

@RoutePage()
class HomePage extends BasePage<HomeCubit, HomeBuildable, HomeListenable> {
  const HomePage({super.key});

  @override
  void init(BuildContext context) {
    // Seed the header name from storage so it shows immediately before the API loads.
    final storage = getIt<Storage>();
    final stored = storage.parentName.call();
    if (stored != null &&
        stored.isNotEmpty &&
        displayNameNotifier.value == null) {
      displayNameNotifier.value = stored;
    }
    context.read<HomeCubit>().initWithLocation();
    super.init(context);
  }

  @override
  void onFocusGained(BuildContext context) {
    // Handles language changes AND post-coupon-purchase discount refresh.
    context.read<HomeCubit>().refreshOnFocusGained();
    super.onFocusGained(context);
  }

  @override
  Widget builder(BuildContext context, HomeBuildable state) {
    final c = context.colors;
    final topInset = MediaQuery.of(context).viewPadding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: c.overlayStyle,
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: topInset + 8.h),
            ValueListenableBuilder<String?>(
              valueListenable: displayNameNotifier,
              builder: (_, nameOverride, __) {
                final storage = getIt<Storage>();
                final name = nameOverride ??
                    state.homeModel?.data?.forUser?.firstName ??
                    storage.parentName.call() ??
                    'User';
                return HomeHeader(
                  name: name,
                  onSearchTap: () => context.router
                      .push(SearchDiscoveryRoute(autofocusSearch: true)),
                  onProfileTap: () => openProfileTab(context),
                );
              },
            ),
            8.verticalSpace,
            Expanded(child: _buildContent(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeBuildable state) {
    if (state.isLoading) return const HomeShimmer();

    final isEmpty = state.homeModel == null &&
        state.newClassesList.isEmpty &&
        state.nearClassesList.isEmpty;
    if (isEmpty) return _ConnectionErrorView(context.read<HomeCubit>());

    // Laid out once per build and shared by the two places that need it: the
    // near list itself, and the end-of-feed ad that stands down when the list
    // has already dealt one.
    final slots = layoutNearYou(
      state.nearClassesList.length,
      _inserts(context, state),
    );
    final adDealt = slots.any(
      (slot) => slot is HomeInsertSlot && slot.insert == HomeInsert.ad,
    );
    final interestsDealt = slots.any(
      (slot) =>
          slot is HomeInsertSlot && slot.insert == HomeInsert.interestsRow,
    );

    return RefreshIndicator(
      color: AppColors.brandPurple,
      onRefresh: () => context.read<HomeCubit>().getHome(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.axis == Axis.vertical &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 300) {
            context.read<HomeCubit>().loadMoreNearClasses();
          }
          return false;
        },
        child: _ScrollsToTop(
          builder: (controller) => CustomScrollView(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: 4.verticalSpace),
              // "Bugun borilishi kerak" — today's visits, above everything the
              // feed is selling. Somewhere to be in two hours beats an offer, so
              // it takes the top of the page whenever there is one; it collapses
              // to nothing on the days there isn't, which is most of them, and
              // the carousel is then the first thing again.
              if (state.todayBookings.isNotEmpty)
                SliverToBoxAdapter(
                  child: TodayBookingsShelf(bookings: state.todayBookings),
                ),
              // Full-bleed promo carousel: the Lumi Start packet leads it, then
              // the API banners.
              SliverToBoxAdapter(
                child: HomeBannerCarousel(
                  banners: state.homeModel?.data?.banners ?? [],
                  packet: state.packet,
                  onAksiyaTap: () => context.router.push(AksiyaRoute()),
                ),
              ),
              if (_categories(state).isNotEmpty)
                SliverToBoxAdapter(child: _buildCategories(context, state)),
              // What a Lumi Coin pack buys, then the courses row.
              //
              // No fallback: with no coin activities to show — the feature off,
              // or a server that predates it — there is no panel at all. Any
              // other row under "Входит в подписку" would claim the pack buys
              // things it does not.
              if (state.subscriptionList.isNotEmpty)
                SliverToBoxAdapter(child: _buildSubscription(context, state)),
              // The interests row is dealt into "Near you" after its first
              // three cards (see [_inserts]). It keeps this slot on a feed too
              // short to have dealt it, and whenever the interests question is
              // still unanswered — the strip asking it belongs up here.
              if (!interestsDealt && _hasInterestsRow(state))
                SliverToBoxAdapter(child: _buildInterestsRow(context, state)),
              if (state.nearClassesList.isNotEmpty)
                ..._buildNearYou(context, state, slots),
              // "Реклама" — normally dealt INTO the near list (see
              // [_inserts]), where it is actually seen: that list paginates
              // without end, so a card placed after it was a card nobody
              // reached. It keeps this slot only on a feed too short to have
              // dealt it — no near list, or fewer cards than it takes to get to
              // its turn.
              if (!adDealt && _adSlot(context, state) != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: _adSlot(context, state),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height:
                      24.h + 64.0 + MediaQuery.of(context).viewPadding.bottom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Whether a card on the home feed carries a price.
  ///
  /// No COURSE on home does. A course is sold as a package — a whole term,
  /// sometimes priced per age bracket — and one figure on a feed card cannot
  /// say which without the wording only the detail page has room for. Home
  /// says what exists; the price is read where it can be explained.
  ///
  /// Activities keep theirs: a ticket is one figure and means one thing.
  static bool _showsPrice(HomClass? item) => !(item?.isCourse ?? false);

  List<HomCategory> _categories(HomeBuildable state) =>
      (state.categories?.isNotEmpty == true)
          ? state.categories!
          : (state.homeModel?.data?.categories?.data ?? []);

  Widget _buildCategories(BuildContext context, HomeBuildable state) {
    final categories = _categories(state);
    if (categories.isNotEmpty) SearchCubit.cachedCategories = categories;

    Widget tile(int index) => CategoryItemWidget(
          key: ValueKey(categories[index].id ?? index),
          homeCategoryModel: categories[index],
          padding: EdgeInsets.zero,
          // A fifth of the row, so five columns exactly fill the screen.
          width: (1.sw - 16.w) / _categoryColumns,
          onTap: () => context.router.push(
            SearchDiscoveryRoute(initialCategory: categories[index]),
          ),
        );

    // The first ten the server sent and no more: the grid is two fixed rows
    // of five and does not scroll. Every category is still one tap away, in
    // search — home shows the ten the adminka put first.
    final columns = categoryGridColumns(
      categories.length.clamp(0, _categoryColumns * 2),
    );
    // A cell holds the artwork and a two-line label. One row of cells when
    // there are too few categories to start a second.
    final cellH = 84.h;
    final rows = columns.any((column) => column.length > 1) ? 2 : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // No header and no "see all": the tiles name themselves.
        14.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: SizedBox(
            height: cellH * rows + (rows - 1) * 4.h,
            // A plain Row, not a list: at most five columns, each a fifth of
            // the width, so there is nothing to scroll to.
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final column in columns)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (row, index) in column.indexed) ...[
                        if (row > 0) 4.verticalSpace,
                        SizedBox(height: cellH, child: tile(index)),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// How many category columns fit across the screen.
  static const _categoryColumns = 5;

  /// The category grid, as columns of indices into the category list.
  ///
  /// It reads like a page: the top row is the first five categories and the
  /// row under it the next five, so the ten the adminka put first are the ten
  /// on show, in order. Home stops there (see [_buildCategories]); given more
  /// than ten, the rest follow in columns of two.
  ///
  /// With five or fewer there is no second row to fill, and each column holds
  /// one.
  static List<List<int>> categoryGridColumns(int count) {
    const perRow = _categoryColumns;
    if (count <= perRow)
      return [
        for (var i = 0; i < count; i++) [i]
      ];
    final columns = <List<int>>[
      for (var c = 0; c < perRow; c++) [c, if (c + perRow < count) c + perRow],
    ];
    for (var i = perRow * 2; i < count; i += 2) {
      columns.add([i, if (i + 1 < count) i + 1]);
    }
    return columns;
  }

  /// The coin row — "Входит в подписку": one-time activities a Lumi Coin
  /// pack pays for, and nothing else. No courses, no catalogue listings — see
  /// `HomeCubit._inThePack`.
  ///
  /// The row is a fixed ten, dealt and shuffled in the cubit (see
  /// `HomeCubit.subscriptionRowSize`), so it is a taste of the catalogue rather
  /// than a list to get to the end of. The panel itself is the way on: a tap
  /// on it anywhere but a card opens the whole catalogue, and the "›" after
  /// the title says so. Not a "see all" link — there is no catalogue filter
  /// for "coins accepted", so "all of these" is not a screen that exists.
  ///
  /// It is drawn as a full-width panel of [AppColorScheme.coinBand] — the
  /// brand violet, pale in light and deep in dark — because what sets this row
  /// apart is that everything in it is already paid for, and the block of
  /// colour is what says so. The entries are raised cards on that panel (see
  /// [HomeCourseCard.carded]), so their text sits on a neutral surface rather
  /// than on the tint.
  ///
  /// Edge to edge: the panel is a band across the feed, not one more inset
  /// tile among the rows. Its rounded corners still show against the page, and
  /// its contents keep the feed's 16pt margin so the header and the first card
  /// line up with the rows above and below.
  ///
  /// No border: the fill alone draws it — see [AppColors.lightCoinBand].
  Widget _buildSubscription(BuildContext context, HomeBuildable state) {
    final c = context.colors;
    final rowH = 126.h + 14.h + 118.h + HomeCourseCard.cardedExtraHeight;
    final row = state.subscriptionList;
    // The row only reaches for another page while it is still short of its
    // ten. Once it is full there is nothing left to fetch for it, so the
    // flick to the end stops asking.
    final wantsMore =
        row.length < HomeCubit.subscriptionRowSize && state.hasMoreNewClasses;
    // Only what the pack buys — the same server rule the row is dealt from.
    void openAll() => context.router
        .push(SearchDiscoveryRoute(initialKind: ActivityKind.coins));
    return GestureDetector(
      // Cards and the scroll claim their own gestures first, so this only
      // fires on the panel around them — the header and the margins.
      behavior: HitTestBehavior.opaque,
      onTap: openAll,
      child: Container(
        // The gap below is the next row's header room: that row adds none of
        // its own, and a title pressed against the panel's rounded corners
        // reads as belonging to it.
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: c.coinBand,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionHeader(
              title: 'included_in_subscription'.tr(),
              chevron: true,
            ),
            12.verticalSpace,
            NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (wantsMore &&
                    scrollInfo.metrics.axis == Axis.horizontal &&
                    scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 8) {
                  context.read<HomeCubit>().loadMoreNewClasses();
                }
                return scrollInfo.metrics.axis == Axis.horizontal;
              },
              child: SizedBox(
                height: rowH,
                child: Stack(
                  children: [
                    ListView.builder(
                      key: const PageStorageKey('subscription-list'),
                      scrollDirection: Axis.horizontal,
                      // The feed's own inset: 8 here plus the card's 8 puts the
                      // first card on the page's 16pt margin, under the header.
                      padding: EdgeInsets.only(left: 8.w, right: 16.w),
                      itemCount: row.length + 1,
                      itemBuilder: (context, index) => index == row.length
                          ? HomeSeeAllTile(onTap: openAll)
                          : HomeCourseCard(
                              key: ValueKey('sub-${row[index].id ?? index}'),
                              homClass: row[index],
                              margin: EdgeInsets.only(left: 8.w),
                              carded: true,
                              // A browsing shelf, not a comparison — see
                              // [HomeCourseCard.showDistance].
                              showDistance: false,
                              showPrice: _showsPrice(row[index]),
                              onViewAsReels: () =>
                                  _openShorts(context, row, index),
                            ),
                    ),
                    if (state.isLoadingNewClasses && wantsMore)
                      Positioned(
                        right: 16.w,
                        top: 0,
                        bottom: 8.h,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasForChildren(HomeBuildable state) =>
      (state.homeModel?.data?.forChildren?.data ?? const []).isNotEmpty;

  /// The banner's tap: the sign-up question, then the row it feeds, reloaded
  /// so the answer is on screen when the parent comes back.
  bool _hasInterestsRow(HomeBuildable state) =>
      state.coursesList.isNotEmpty ||
      state.homeModel?.data?.interestsPicked == false;

  /// The interests question (for an account that was never asked it), then
  /// the row it feeds.
  Widget _buildInterestsRow(BuildContext context, HomeBuildable state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // An account from before the interests question has never been
        // asked it, and without an answer the row below can only be the
        // generic courses. Asked here, where the answer shows up.
        if (state.homeModel?.data?.interestsPicked == false)
          Padding(
            // Room above for the artwork, which stands out of the strip.
            padding: EdgeInsets.only(top: 12.h, bottom: 18.h),
            child: HomeInterestsStrip(onTap: () => _askInterests(context)),
          ),
        // REAL courses — the backend keeps these out of the class lists, so
        // this row is the only place they appear. Ordered to walk across
        // categories rather than to sit in whatever order the feed sent.
        if (state.coursesList.isNotEmpty)
          _buildCoursesRow(
            context,
            // Picked for this parent's children when they have chosen
            // topics, otherwise the generic spread — decided in the
            // cubit, where the feed lands.
            state.coursesList,
            forChildren: _hasForChildren(state),
          ),
      ],
    );
  }

  Future<void> _askInterests(BuildContext context) async {
    final cubit = context.read<HomeCubit>();
    if (await askInterestsFromHome(context.router.root)) {
      await cubit.refreshSilently();
    }
  }

  /// A generic horizontal course row, reusing whichever list is passed in.
  ///
  /// With [forChildren] it is "На основе ваших интересов": what the server
  /// picked for this parent's children — activities and courses together,
  /// each card naming the child it is for. Without it, the generic courses in
  /// a category spread, headed as what they are: nothing in it was picked
  /// from anyone's interests.
  Widget _buildCoursesRow(
    BuildContext context,
    List<HomClass> list, {
    bool forChildren = false,
  }) {
    // Sized so ONE AND A HALF cards fill the screen: the half-card at the right
    // edge is what says the row scrolls, and a course card carries more to read
    // than an activity's — a provider tag, a title, an address, and a price
    // line that runs to two lines when it quotes a trial — so the width is what
    // keeps all of that off the ellipsis.
    //
    // The 24 is the row's own left inset (8 of list padding + the card's 8
    // margin) plus the 8 gap before the half-card, so the arithmetic is against
    // the space a card actually gets rather than the raw screen.
    //
    // Clamped at the top for tablets, where a strict 1.5 would produce a card
    // wider than the phone this row was designed on; at the bottom so a narrow
    // phone never goes below the width the text was fitted to.
    //
    // Sized per build, not once: this scales against the current screen, so a
    // value cached in a static would be stale on the first rotation.
    final cardW = ((1.sw - 24.w) / 1.5).clamp(200.0, 320.0);
    // FIXED, deliberately not derived from [cardW]: only the width follows the
    // screen. Tying the photo's height to the width made the whole card grow
    // taller as it widened, which is the row getting bigger rather than the
    // card getting wider. It is the height the 200-wide card had, so the frame
    // simply shows more of the photo instead of standing taller.
    final cardImgH = 150.w;
    // The text block under the photo: a provider pill, a one-line title and an
    // address. NOT a price — a course on the feed carries none (see
    // [_showsPrice]) — which is why this is no longer the 118 the priced rows
    // reserve. Holding on to that figure left ~35pt of nothing at the bottom of
    // every card, which the eye read as a gap between this row and "Sizga
    // yaqin" under it rather than as part of the cards.
    //
    // Measured rather than estimated — see `home_courses_row_height_test.dart`,
    // which fails if a card outgrows this or if the slack creeps back.
    //
    // The 118 branch stands for the day something priced lands in this list:
    // the row would otherwise clip the price line off it.
    //
    // Scaled by the device's text size, so a large-font setting makes the row
    // taller instead of cutting the address off the bottom. Clamped, because
    // past 1.6 the row would be taller than the photo it belongs to.
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
    //
    // The 118 is for a price that runs to TWO lines, and only one kind does:
    // a so'm figure struck out over the coupon plan's discounted one. A coin
    // price is a single line, and so is a so'm price with no plan — and on
    // those the second line's worth of room sat empty under every card,
    // where it read as a hole in the feed before "Sizga yaqin". So the full
    // allowance is kept for the case that fills it, and the rest get one
    // line's less.
    final app =
        context.watch<AppCubit>().state.buildable ?? const AppBuildable();
    final strikesPrice = app.hasPremium &&
        app.planDiscountPercentage > 0 &&
        !watchNewCoins(context).isVisible;
    final priceBlock = strikesPrice ? 118.0 : 102.0;
    final textBlock = (list.any(_showsPrice) ? priceBlock : 84.0) * textScale;
    // Carded on a coloured panel, like "Obunaga kiradi", so the card adds its
    // own frame around the photo and text.
    final rowH = cardImgH + 14.h + textBlock.h + HomeCourseCard.cardedExtraHeight;
    void openAll() => context.router.push(
          forChildren
              ? InterestsGridRoute(title: 'based_on_interests'.tr())
              : SearchDiscoveryRoute(initialKind: ActivityKind.courses),
        );
    // The same panel as "Obunaga kiradi" — the coin band's colour and shape —
    // so the two horizontal shelves on the feed read as one family, distinct
    // from the plain "Sizga yaqin" list around them.
    //
    // The children's row opens the rest of its own matches — the same
    // matching, uncapped, with a chip per topic. The whole catalog would
    // answer a question the header did not ask. The generic row opens the
    // discovery screen narrowed to courses — it named a type, so "see all"
    // honours it.
    return GestureDetector(
      // As on "Obunaga kiradi": a chevron on the title, and the whole panel
      // around the cards is the tap. The cards claim their own taps first.
      behavior: HitTestBehavior.opaque,
      onTap: openAll,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: context.colors.coinBand,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionHeader(
              title: forChildren ? 'based_on_interests'.tr() : 'courses'.tr(),
              chevron: true,
            ),
            12.verticalSpace,
            SizedBox(
              height: rowH,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: 8.w, right: 16.w),
                itemCount: list.length + 1,
                itemBuilder: (context, index) => index == list.length
                    ? HomeSeeAllTile(onTap: openAll)
                    : HomeCourseCard(
                        key: ValueKey('c2-${list[index].id ?? index}'),
                        homClass: list[index],
                        width: cardW,
                        imageHeight: cardImgH,
                        margin: EdgeInsets.only(left: 8.w),
                        carded: true,
                        // Same shelf treatment as the activities row above it.
                        showDistance: false,
                        showPrice: _showsPrice(list[index]),
                        onViewAsReels: () => _openShorts(context, list, index),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The banner used for the full-width "Реклама" slot: the last one the feed
  /// sent, and only if it has somewhere to go. Returns null otherwise, which
  /// collapses the slot — an ad card that opens nothing is worse than no card.
  HomBanner? _adBanner(HomeBuildable state) {
    final banners = state.homeModel?.data?.banners ?? [];
    if (banners.isEmpty) return null;
    final last = banners.last;
    return last.hasLink ? last : null;
  }

  String _bannerSrc(HomBanner banner) {
    final raw = (banner.url ?? '').replaceAll(RegExp(r'\s+'), '').trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.isNotEmpty) return '${Constants.assetsUrl}$raw';
    return '${Constants.assetsUrl}${banner.id ?? ''}';
  }

  /// How many cards a coloured band needs before it is worth dealing. Under
  /// this it is a wide panel with a card or two adrift in it.
  static const int _bandMinimum = 3;

  /// The most a band shows. A shelf to glance along, not a second catalogue.
  static const int _bandMaximum = 10;

  /// Everything the feed has loaded, each activity once — the pool the
  /// coloured bands are picked from. No request of their own: a band is a
  /// different cut of what is already on the page.
  List<HomClass> _loaded(HomeBuildable state) {
    final seen = <String>{};
    return [
      for (final c in [
        ...state.newClassesList,
        ...state.coursesList,
        ...state.nearClassesList,
      ])
        if (c.id == null || seen.add(c.id!)) c,
    ];
  }

  List<HomClass> _trials(HomeBuildable state) => _loaded(state)
      .where((c) => c.trialEnabled ?? false)
      .take(_bandMaximum)
      .toList();

  List<HomClass> _discounted(HomeBuildable state) =>
      _loaded(state).where((c) => c.sale != null).take(_bandMaximum).toList();

  /// What may interrupt "Near you" on THIS feed, in dealing order.
  ///
  /// Each entry is here only if it has something to show or somewhere to go:
  /// a band needs its cards, a banner for an account feature needs an
  /// account, the coin banner needs the coin feature to be live. Leaving one
  /// out closes the gap — the next takes its turn — so the feed never holds
  /// an empty panel or a banner that opens a dead end.
  List<HomeInsert> _inserts(BuildContext context, HomeBuildable state) {
    final signedIn = context.read<HomeCubit>().isSignedIn;
    final coinsLive = watchNewCoins(context).isVisible;
    final fixed = [
      for (final insert in HomeInsert.values)
        if (switch (insert) {
          // Not while the interests question is still unanswered: the strip
          // that asks it then keeps its fixed slot under the coin row, where
          // it is seen before the near list starts.
          HomeInsert.interestsRow => _hasInterestsRow(state) &&
              state.homeModel?.data?.interestsPicked != false,
          HomeInsert.inviteBanner => signedIn,
          HomeInsert.categoryTiles => _categories(state).length >= 4,
          HomeInsert.trialBand => _trials(state).length >= _bandMinimum,
          HomeInsert.coinBanner => coinsLive,
          HomeInsert.centres => state.centres.length >= _bandMinimum,
          // Real sales are rare and each is worth showing, so this band does
          // not wait for three of them the way the trial band does.
          HomeInsert.discountBand => _discounted(state).isNotEmpty,
          HomeInsert.savedBanner => signedIn,
          HomeInsert.ad => state.packet != null || _adBanner(state) != null,
          // Not one of the fixed ones: woven in below, once per row.
          HomeInsert.unclaimedShelf => false,
        })
          insert,
    ];
    return weaveShelves(fixed, state.unclaimedShelves.length);
  }

  /// The feed's one advertisement, or null when there is nothing to advertise.
  ///
  /// The packet gets it whenever one is on sale: it is the offer with a
  /// deadline on it, and the card quotes its real name, visit count and price
  /// straight off the live campaign, so the ad can never advertise a price
  /// marketing has already changed. A picture ad cannot do that — it says
  /// whatever it said the day it was uploaded.
  ///
  /// The adminka's own banner takes it when there is no packet. That banner
  /// opens its OWN link and is left out entirely when it has none, rather
  /// than showing an ad that lies about where it goes.
  Widget? _adSlot(BuildContext context, HomeBuildable state) {
    final packet = state.packet;
    if (packet != null) {
      return HomeAksiyaAdCard(
        campaign: packet,
        onTap: () => context.router.push(AksiyaRoute()),
      );
    }
    final banner = _adBanner(state);
    if (banner == null) return null;
    return HomeAdCard(
      imageUrl: _bannerSrc(banner),
      onTap: () => openBanner(banner, placement: BannerPlacement.homeAd),
    );
  }

  /// "Near you", opening in runs of two or three cards with something else
  /// between each run, each insert shown once — see [layoutNearYou].
  ///
  /// It used to be one unbroken list: a screen and a half of identical cards,
  /// then another, without end. The cards are the same and in the same order;
  /// what changed is that the eye gets a different shape every few rows — a
  /// coupon, a band of colour, a grid of tiles — which is also the only place
  /// on the feed the app's own features are ever mentioned.
  List<Widget> _buildNearYou(
    BuildContext context,
    HomeBuildable state,
    List<HomeFeedSlot> slots,
  ) {
    return [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            8.verticalSpace,
            HomeSectionHeader(title: 'near_you'.tr()),
            10.verticalSpace,
          ],
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final slot = slots[i];
            final isLast = i == slots.length - 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                switch (slot) {
                  HomeNearSlot(:final index) => HomeNearbyCard(
                      key: ValueKey(state.nearClassesList[index].id ?? index),
                      homClass: state.nearClassesList[index],
                      // "Near you" carries courses as well as activities, so
                      // the price is dropped per entry rather than for the
                      // list.
                      showPrice: _showsPrice(state.nearClassesList[index]),
                      onViewAsReels: () =>
                          _openShorts(context, state.nearClassesList, index),
                    ),
                  HomeInsertSlot() => _buildInsert(context, state, slot),
                },
                // Each card carries its own frosted edge and shadow, so the
                // gap alone separates one entry from the next. The last one
                // gets less air: there is nothing after it to divide from.
                if (!isLast) 16.verticalSpace else 12.verticalSpace,
              ],
            );
          },
          childCount: slots.length,
        ),
      ),
      if (state.isLoadingNearClasses)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child:
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
    ];
  }

  Widget _buildInsert(
    BuildContext context,
    HomeBuildable state,
    HomeInsertSlot slot,
  ) {
    switch (slot.insert) {
      case HomeInsert.interestsRow:
        return _buildInterestsRow(context, state);
      case HomeInsert.inviteBanner:
        return HomeTicketBanner(
          color: AppColors.brandPurple,
          title: 'home_invite_title'.tr(),
          subtitle: 'home_invite_subtitle'.tr(),
          art: Assets.images.banner.bannerInvite,
          onTap: () => context.router.push(const ReferralRoute()),
        );
      case HomeInsert.coinBanner:
        return HomeTicketBanner(
          color: AppColors.coinGold,
          // White cannot be read on gold.
          onColor: AppColors.ink,
          title: 'home_coins_title'.tr(),
          subtitle: 'home_coins_subtitle'.tr(),
          art: Assets.images.banner.bannerCoins,
          onTap: () => context.router.push(NewCoinsRoute()),
        );
      case HomeInsert.savedBanner:
        return HomeTicketBanner(
          color: AppColors.brandPink,
          title: 'home_saved_title'.tr(),
          subtitle: 'home_saved_subtitle'.tr(),
          art: Assets.images.banner.bannerSaved,
          onTap: () => context.router.push(const SavedActivitiesRoute()),
        );
      case HomeInsert.categoryTiles:
        return HomeCategoryTiles(
          categories:
              context.read<HomeCubit>().categoryTiles(_categories(state)),
          onTap: (category) => context.router.push(
            SearchDiscoveryRoute(initialCategory: category),
          ),
        );
      case HomeInsert.trialBand:
        return _buildBand(
          context,
          title: 'trial_lessons'.tr(),
          list: _trials(state),
          color: context.colors.trialBand,
          storageKey: 'trial-band',
        );
      case HomeInsert.discountBand:
        return _buildBand(
          context,
          title: 'home_discounts_title'.tr(),
          list: _discounted(state),
          color: context.colors.discountBand,
          storageKey: 'discount-band',
        );
      case HomeInsert.centres:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionHeader(
              title: 'home_centres_title'.tr(),
              onViewAll: () => context.router.push(BranchesMapRoute()),
              viewAllLabel: 'centers_on_map'.tr(),
            ),
            12.verticalSpace,
            HomeCentresShelf(
              branches: state.centres,
              onSeeAll: () => context.router.push(BranchesMapRoute()),
            ),
          ],
        );
      case HomeInsert.unclaimedShelf:
        // [_inserts] deals one per row, so the ordinal is always a row —
        // unless the rows were refetched shorter between layout and build.
        final shelves = state.unclaimedShelves;
        if (slot.ordinal >= shelves.length) return const SizedBox.shrink();
        return _buildUnclaimed(shelves[slot.ordinal]);
      case HomeInsert.ad:
        // [_inserts] deals this only when there is one.
        return _adSlot(context, state) ?? const SizedBox.shrink();
    }
  }

  /// One of the adminka's rows of open-source centres, dealt into "Near you".
  Widget _buildUnclaimed(UnclaimedShelf shelf) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: shelf.title),
        12.verticalSpace,
        HomeUnclaimedShelf(
          centres: shelf.centres,
          storageKey: 'unclaimed-shelf-${shelf.id}',
        ),
      ],
    );
  }

  /// A full-width block of colour holding one horizontal row of cards — the
  /// shape [_buildSubscription] introduced, for the bands dealt into "Near
  /// you". Edge to edge and unbordered for the reasons given there.
  ///
  /// Unlike that row it does not paginate: its cards are a cut of what the
  /// feed already loaded (see [_loaded]), so there is no next page to ask for.
  Widget _buildBand(
    BuildContext context, {
    required String title,
    required List<HomClass> list,
    required Color color,
    required String storageKey,
  }) {
    final rowH = 126.h + 14.h + 118.h + HomeCourseCard.cardedExtraHeight;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(title: title),
          12.verticalSpace,
          SizedBox(
            height: rowH,
            child: ListView.builder(
              key: PageStorageKey(storageKey),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 8.w, right: 16.w),
              itemCount: list.length,
              itemBuilder: (context, index) => HomeCourseCard(
                key: ValueKey('$storageKey-${list[index].id ?? index}'),
                homClass: list[index],
                margin: EdgeInsets.only(left: 8.w),
                carded: true,
                showDistance: false,
                showPrice: _showsPrice(list[index]),
                onViewAsReels: () => _openShorts(context, list, index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openShorts(BuildContext context, List<HomClass> feed, int index) {
    ShortsFeed.set(feed, index);
    context.tabsRouter.setActiveIndex(_kShortsTabIndex);
  }
}

/// "No internet" state (Figma `Ошибка подключения к интернету`).
class _ConnectionErrorView extends StatelessWidget {
  const _ConnectionErrorView(this.cubit);

  final HomeCubit cubit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: c.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.wifi_slash,
                  size: 32.sp, color: c.textSecondary),
            ),
            20.verticalSpace,
            Text(
              'no_internet_title'.tr(),
              textAlign: TextAlign.center,
              style: AppText.bold18.copyWith(color: c.textPrimary),
            ),
            8.verticalSpace,
            Text(
              'no_internet_desc'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular14.copyWith(color: c.textSecondary),
            ),
            28.verticalSpace,
            SizedBox(
              width: 200.w,
              child: GradientButton(
                text: 'retry'.tr(),
                onPressed: () => cubit.getHome(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Owns the feed's scroll controller so the Home tab can send it back to the
/// top — see [homeScrollToTop]. [HomePage] is a stateless [BasePage], so the
/// controller needs a State of its own to live and be disposed in.
class _ScrollsToTop extends StatefulWidget {
  const _ScrollsToTop({required this.builder});

  final Widget Function(ScrollController controller) builder;

  @override
  State<_ScrollsToTop> createState() => _ScrollsToTopState();
}

class _ScrollsToTopState extends State<_ScrollsToTop> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    homeScrollToTop.addListener(_toTop);
  }

  @override
  void dispose() {
    homeScrollToTop.removeListener(_toTop);
    _controller.dispose();
    super.dispose();
  }

  void _toTop() {
    if (!_controller.hasClients || _controller.offset <= 0) return;
    // A long feed jumps most of the way first: animating ten screens of
    // cards reads as a slow slide rather than "back to the top".
    final screen = _controller.position.viewportDimension;
    if (_controller.offset > screen * 3) _controller.jumpTo(screen * 3);
    _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller);
}
