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
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/main_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/catgory_item_widget.dart';
import 'package:lumi_pass/domain/repo/banners/banner_click_reporter.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_banners.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_class_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_common.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_header.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_skeletons.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/today_bookings.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/shorts/shorts_feed.dart';

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
    if (stored != null && stored.isNotEmpty && displayNameNotifier.value == null) {
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
        child: CustomScrollView(
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
            // the coupon card, then the API banners.
            SliverToBoxAdapter(
              child: HomeBannerCarousel(
                banners: state.homeModel?.data?.banners ?? [],
                packet: state.packet,
                onCouponTap: () => context.router.push(const PlansRoute()),
                onAksiyaTap: () => context.router.push(AksiyaRoute()),
              ),
            ),
            if (_categories(state).isNotEmpty)
              SliverToBoxAdapter(child: _buildCategories(context, state)),
            // What a Lumi Coin pack buys, then the courses row.
            //
            // The fallback is not cosmetic: on a server that sends no coin
            // prices at all — the feature off, or a backend that predates it —
            // the subscription row would be empty and home would be left with
            // no activities shelf whatsoever. It falls back to the row that
            // used to be here, under its OWN old header: "Входит в подписку"
            // over activities a pack cannot pay for is a promise the feed
            // cannot keep.
            if (state.subscriptionList.isNotEmpty)
              SliverToBoxAdapter(child: _buildSubscription(context, state))
            else if (state.newClassesList.isNotEmpty)
              SliverToBoxAdapter(child: _buildPopular(context, state)),
            // REAL courses — the backend keeps these out of the class lists, so
            // this row is the only place they appear. Ordered to walk across
            // categories rather than to sit in whatever order the feed sent.
            if (state.coursesList.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildCoursesRow(
                  context,
                  'based_on_interests'.tr(),
                  // Already walked across categories by the cubit, where the
                  // feed lands — see [HomeCubit.coursesAcrossCategories].
                  state.coursesList,
                ),
              ),
            if (state.nearClassesList.isNotEmpty)
              ..._buildNearYou(context, state),
            // "Реклама" — the last slot on the feed, full width.
            //
            // The packet gets it whenever one is on sale: it is the offer with
            // a deadline on it, and the card quotes its real name, visit count
            // and price straight off the live campaign, so the ad can never
            // advertise a price marketing has already changed. A picture ad
            // cannot do that — it says whatever it said the day it was
            // uploaded.
            //
            // The adminka's own banner keeps the slot when there is no packet.
            // That banner opens its OWN link (it used to send every tap to the
            // plans screen regardless of what it advertised) and is left out
            // entirely when it has none, rather than showing an ad that lies
            // about where it goes. With neither, the slot simply isn't there.
            if (state.packet != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: HomeAksiyaAdCard(
                    campaign: state.packet!,
                    onTap: () => context.router.push(AksiyaRoute()),
                  ),
                ),
              )
            else if (_adBanner(state) != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: HomeAdCard(
                    imageUrl: _bannerSrc(_adBanner(state)!),
                    onTap: () => openBanner(
                      _adBanner(state)!,
                      placement: BannerPlacement.homeAd,
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 24.h +
                    64.0 +
                    MediaQuery.of(context).viewPadding.bottom,
              ),
            ),
          ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.verticalSpace,
        // No "see all": the row already scrolls through every category, so the
        // grid it used to open was the same list a second time.
        HomeSectionHeader(title: 'all_categories'.tr()),
        10.verticalSpace,
        SizedBox(
          // Tall enough for a two-line label under the artwork, so a wrapped
          // title doesn't overflow the row.
          height: 112.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // 8pt between tiles; the leading 8 here plus the tile's own 8 keep
            // the first one on the page's 16pt margin.
            padding: EdgeInsets.only(left: 8.w, right: 16.w),
            itemCount: categories.length,
            itemBuilder: (context, index) => CategoryItemWidget(
              key: ValueKey(categories[index].id ?? index),
              homeCategoryModel: categories[index],
              padding: EdgeInsets.only(left: 8.w),
              onTap: () => context.router.push(
                SearchDiscoveryRoute(initialCategory: categories[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// "Входит в подписку" — a sample of what a Lumi Coin pack pays for.
  ///
  /// The row is a fixed ten, dealt and shuffled in the cubit (see
  /// `HomeCubit.subscriptionRowSize`), so it is a taste of the catalogue rather
  /// than a list to get to the end of. It carries NO "see all": there is no
  /// catalogue filter for "coins accepted", so the only screen a tap could
  /// open is the unfiltered one — which would answer a question the header did
  /// not ask. The categories row above leaves its own off for the same reason.
  ///
  /// It is drawn as a container of pale [AppColorScheme.coinBand] gold — the
  /// coin's own colour — because what sets this row apart is not the cards,
  /// which are the feed's ordinary ones, but that everything in it is already
  /// paid for. The block of colour is what says so.
  ///
  /// No border: the fill alone draws it. That makes the fill the ONLY thing
  /// separating the container from the feed, which is why the gold is held
  /// where it is — see [AppColors.lightCoinBand].
  ///
  /// It carries no vertical margin and the rows either side of it add none, so
  /// the container sits flush between the lists above and below rather than
  /// floating in a gap of its own.
  Widget _buildSubscription(BuildContext context, HomeBuildable state) {
    final c = context.colors;
    final rowH = 126.h + 14.h + 118.h;
    final row = state.subscriptionList;
    // The row only reaches for another page while it is still short of its
    // ten. Once it is full there is nothing left to fetch for it, so the
    // flick to the end stops asking.
    final wantsMore =
        row.length < HomeCubit.subscriptionRowSize && state.hasMoreNewClasses;
    return Container(
      // Still inset from the page edges rather than full-bleed: with the
      // border gone the rounded corners are the only thing giving the block a
      // shape, and they need room to be seen.
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: c.coinBand,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(title: 'included_in_subscription'.tr()),
          8.verticalSpace,
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
                    // Smaller than the other rows': theirs clears the page
                    // margin, this one only has to clear the container's own
                    // border a few pixels away.
                    padding: EdgeInsets.only(left: 0, right: 8.w),
                    itemCount: row.length,
                    itemBuilder: (context, index) => HomeCourseCard(
                      key: ValueKey('sub-${row[index].id ?? index}'),
                      homClass: row[index],
                      margin: EdgeInsets.only(left: 8.w),
                      // A browsing shelf, not a comparison — see
                      // [HomeCourseCard.showDistance].
                      showDistance: false,
                      showPrice: _showsPrice(row[index]),
                      onViewAsReels: () => _openShorts(context, row, index),
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
    );
  }

  /// The row this feed used to lead with: "Mashhur mashg'ulotlar", whatever
  /// the adminka featured, paginating as it is scrolled.
  ///
  /// Kept only as [_buildSubscription]'s fallback — see the feed above.
  Widget _buildPopular(BuildContext context, HomeBuildable state) {
    final rowH = 126.h + 14.h + 118.h;
    // Whatever the adminka has FEATURED, course or class alike. The row is the
    // centre's own pick, and a course it picked is as much that as a class is —
    // the card prices each its own way off `is_course`, the same as "Near you",
    // which has always carried both.
    final popular = state.newClassesList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.verticalSpace,
        HomeSectionHeader(
          title: 'popular_activities'.tr(),
          // Everything on offer, searchable and filterable. This row is a
          // popularity row rather than a type, so it narrows to nothing.
          onViewAll: () => context.router.push(
            SearchDiscoveryRoute(),
          ),
          // Names what the tap lands on, the same way the courses row below
          // does. Its own key rather than the generic `view_all`, which the
          // schedule screen also uses and which must stay put.
          viewAllLabel: 'view_all_activities'.tr(),
        ),
        10.verticalSpace,
        NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.axis == Axis.horizontal &&
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
                  key: const PageStorageKey('new-classes-list'),
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: 8.w, right: 16.w),
                  itemCount: popular.length,
                  itemBuilder: (context, index) => HomeCourseCard(
                    key: ValueKey(popular[index].id ?? index),
                    homClass: popular[index],
                    margin: EdgeInsets.only(left: 8.w),
                    // A browsing shelf, not a comparison — see
                    // [HomeCourseCard.showDistance].
                    showDistance: false,
                    showPrice: _showsPrice(popular[index]),
                    onViewAsReels: () =>
                        _openShorts(context, popular, index),
                  ),
                ),
                if (state.isLoadingNewClasses)
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
    );
  }

  /// A generic horizontal course row, reusing whichever list is passed in.
  ///
  /// Carries the feed's "На основе ваших интересов" row. The header names
  /// interests but the ORDER is a category spread — see
  /// [HomeCubit.coursesAcrossCategories] for why, and for what a genuinely
  /// interest-ranked row would need first.
  Widget _buildCoursesRow(
      BuildContext context, String title, List<HomClass> list) {
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
    final textScale =
        MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
    final textBlock = (list.any(_showsPrice) ? 118.0 : 84.0) * textScale;
    final rowH = cardImgH + 14.h + textBlock.h;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // No leading gap: this row follows the coin container, and the two
        // lists are meant to sit flush. The container draws its own edge, so
        // the space a header normally needs above it is already there.
        HomeSectionHeader(
          title: title,
          // The same discovery screen the activities row opens, narrowed to
          // courses — this row named a type, so "see all" honours it. It lands
          // as a visible filter rather than a mode, so the user can widen back
          // to everything from the filter sheet.
          onViewAll: () => context.router.push(
            SearchDiscoveryRoute(initialKind: ActivityKind.courses),
          ),
          // Named rather than generic, because the tap is narrowed to courses.
          viewAllLabel: 'view_all_courses'.tr(),
        ),
        10.verticalSpace,
        SizedBox(
          height: rowH,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 8.w, right: 16.w),
            itemCount: list.length,
            itemBuilder: (context, index) => HomeCourseCard(
              key: ValueKey('c2-${list[index].id ?? index}'),
              homClass: list[index],
              width: cardW,
              imageHeight: cardImgH,
              margin: EdgeInsets.only(left: 8.w),
              // Same shelf treatment as the activities row above it.
              showDistance: false,
              showPrice: _showsPrice(list[index]),
              onViewAsReels: () => _openShorts(context, list, index),
            ),
          ),
        ),
      ],
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

  List<Widget> _buildNearYou(BuildContext context, HomeBuildable state) {
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
          (context, index) {
            final isLast = index == state.nearClassesList.length - 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeNearbyCard(
                  key: ValueKey(state.nearClassesList[index].id ?? index),
                  homClass: state.nearClassesList[index],
                  // "Near you" carries courses as well as activities, so the
                  // price is dropped per entry rather than for the list.
                  showPrice: _showsPrice(state.nearClassesList[index]),
                  onViewAsReels: () =>
                      _openShorts(context, state.nearClassesList, index),
                ),
                // Each card now carries its own frosted edge and shadow, so
                // the gap alone separates one entry from the next — the rule
                // that used to sit here would only fight that edge. The last
                // one gets less air: there is nothing after it to divide from.
                if (!isLast) 16.verticalSpace else 12.verticalSpace,
              ],
            );
          },
          childCount: state.nearClassesList.length,
        ),
      ),
      if (state.isLoadingNearClasses)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
    ];
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
