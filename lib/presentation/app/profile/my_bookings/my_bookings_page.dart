import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/segmented_tab_switch.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/main/main_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/widget/schedule_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

/// Profile → My Bookings. A full-width two-way switch splits the order list
/// into Active (paid/cancelled with a future ticket date) and Past (everything
/// else); the Active side opens with how a visit gets confirmed. Uses the same
/// [BookingCard] the Bookings tab renders.
///
/// Both the Bronlar tab (third slot of the bottom bar) and a pushed screen
/// (Profile's "Bronlarim" tile, booking pushes, Home's today-bookings row).
@RoutePage()
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final _pages = PageController();

  List<UserOrder> _orders = const [];
  bool _loading = true;
  String? _error;

  /// Continuous page offset, driving the switcher's sliding pill. Fractional
  /// while a swipe is in flight, whole once it settles.
  double _position = 0;

  @override
  void initState() {
    super.initState();
    _pages.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _pages.removeListener(_onScroll);
    _pages.dispose();
    super.dispose();
  }

  void _onScroll() {
    // `page` is null until the PageView has been laid out.
    final page = _pages.positions.isEmpty ? null : _pages.page;
    if (page == null || page == _position) return;
    setState(() => _position = page);
  }

  void _select(int index) => _pages.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await getIt<OrdersApi>().getOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Active = paid or cancelled with a ticket date today or in the future.
  bool _isActive(UserOrder o) =>
      (o.isPaid || o.isCanceled) && o.hasFutureTicket;

  bool get _hasRealToken => getIt<Storage>().tokens.call()?.access != null;

  bool get _showLoginPrompt =>
      RemoteConfigService.instance.isInReview && !_hasRealToken;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // `GET orders` returns every order type, and only an activity order is a
    // booking. A Lumi Coin pack (like a packet or a shop order) has no
    // activity and no tickets, so without this it read as a paid booking with
    // a future date and sat in "active" as an empty card.
    final visible =
        _orders.where((o) => o.isActivityOrder && !o.isPending).toList();
    final active = visible.where(_isActive).toList();
    final past = visible.where((o) => !_isActive(o)).toList();

    // As a tab it is a root with nothing behind it, so no back chip. Asked of
    // the router's TYPE, not `canPop()` — see `NewCoinsPage`.
    final isTab = context.router is TabsRouter;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: BaseAppBar(
        title: 'my_bookings'.tr(),
        leading: isTab ? const SizedBox.shrink() : null,
      ),
      body: _showLoginPrompt
          ? const _LoginPrompt()
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
                  child: SegmentedTabSwitch(
                    labels: ['active_bookings'.tr(), 'past_bookings'.tr()],
                    position: _position,
                    onSelect: _select,
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const _Shimmer()
                      : _error != null
                          ? _ErrorState(onRetry: _load)
                          : PageView(
                              controller: _pages,
                              children: [
                                _OrdersList(
                                  orders: active,
                                  onRefresh: _load,
                                  header: const _HowToConfirmCard(),
                                  emptyTitle: 'bookings_empty_upcoming'.tr(),
                                ),
                                _OrdersList(
                                  orders: past,
                                  onRefresh: _load,
                                  emptyTitle: 'bookings_empty_past'.tr(),
                                ),
                              ],
                            ),
                ),
              ],
            ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({
    required this.orders,
    required this.onRefresh,
    required this.emptyTitle,
    this.header,
  });

  final List<UserOrder> orders;
  final Future<void> Function() onRefresh;
  final String emptyTitle;

  /// Scrolls with the list, above the cards or the empty state.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: onRefresh,
      child: ListView(
        // `padding`, not `viewPadding`: on the tab the tabs scaffold runs
        // `extendBody: true`, which reports the floating nav pill here, so the
        // last card scrolls clear of it.
        padding: EdgeInsets.fromLTRB(
          16.w,
          4.h,
          16.w,
          24.h + MediaQuery.paddingOf(context).bottom,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (header != null) ...[header!, 20.verticalSpace],
          if (orders.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: header == null ? 96.h : 24.h),
              child: _EmptyState(title: emptyTitle),
            )
          else
            for (final o in orders) BookingCard(order: o),
        ],
      ),
    );
  }
}

/// "How is a visit confirmed?" — the three steps between booking and a
/// "Visited" status: come, give the ticket number, the centre marks it in the
/// partner bot. Folded by default — one tap opens it, and whichever way the
/// parent leaves it is remembered on the device.
class _HowToConfirmCard extends StatefulWidget {
  const _HowToConfirmCard();

  @override
  State<_HowToConfirmCard> createState() => _HowToConfirmCardState();
}

class _HowToConfirmCardState extends State<_HowToConfirmCard> {
  static const _prefsKey = 'bookings_how_to_confirm_collapsed';

  /// Kept for the session too, so flipping tabs does not re-read prefs and
  /// flash the card open.
  static bool? _collapsedCache;

  /// Folded until told otherwise: arriving on the page used to show the card
  /// open, then fold it shut as soon as the saved choice was read.
  bool _collapsed = _collapsedCache ?? true;

  /// Only the parent's own tap animates. Resolving the saved choice snaps,
  /// so the page never visibly reshapes itself on arrival.
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    if (_collapsedCache != null) return;
    SharedPreferences.getInstance().then((prefs) {
      final v = prefs.getBool(_prefsKey) ?? true;
      _collapsedCache = v;
      if (mounted && v != _collapsed) setState(() => _collapsed = v);
    }).catchError((_) {});
  }

  void _toggle() {
    final next = !_collapsed;
    _collapsedCache = next;
    setState(() {
      _collapsed = next;
      _animate = true;
    });
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(_prefsKey, next))
        .catchError((_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: AnimatedSize(
        duration: _animate ? const Duration(milliseconds: 240) : Duration.zero,
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'how_to_confirm_title'.tr(),
                        style: AppText.semibold16
                            .copyWith(color: colors.textPrimary),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _collapsed ? 0.5 : 0,
                      duration: _animate
                          ? const Duration(milliseconds: 240)
                          : Duration.zero,
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 24.sp,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!_collapsed) ...[
              4.verticalSpace,
              for (final (i, key) in const [
                'how_to_confirm_step1',
                'how_to_confirm_step2',
                'how_to_confirm_step3',
              ].indexed) ...[
                _Step(number: i + 1, text: key.tr()),
                if (i < 2) 12.verticalSpace,
              ],
              14.verticalSpace,
              Text(
                'how_to_confirm_note'.tr(),
                style: AppText.regular13.copyWith(color: colors.textSecondary),
              ),
              14.verticalSpace,
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggle,
                child: Container(
                  height: 44.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.control,
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Text(
                    'collapse'.tr(),
                    style:
                        AppText.semibold14.copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
              12.verticalSpace,
            ],
          ],
        ),
      ),
    );
  }
}

/// A numbered step: the number in a tinted brand circle, the text beside it.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26.w,
          height: 26.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: AppText.semibold14.copyWith(color: colors.primary),
          ),
        ),
        12.horizontalSpace,
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Text(
              text,
              style: AppText.regular14.copyWith(color: colors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title});

  final String title;

  /// To the search tab: as a tab, switch to it; pushed from Profile, come back
  /// down to the tabs first.
  void _findLesson(BuildContext context) {
    final tabs = context.router.root.innerRouterOf<TabsRouter>(MainRoute.name);
    tabs?.setActiveIndex(searchTabIndex);
    if (context.router is! TabsRouter) {
      context.router.popUntil((r) => r.settings.name == MainRoute.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Assets.images.mascot.mascotCalendar.image(
          width: 180.w,
          height: 180.w,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
        16.verticalSpace,
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppText.semibold18.copyWith(color: colors.textPrimary),
        ),
        20.verticalSpace,
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _findLesson(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: AppGradients.indigo,
              borderRadius: BorderRadius.circular(48.r),
            ),
            child: Text(
              'find_lesson'.tr(),
              style: AppText.semibold16.copyWith(color: AppColors.onBrand),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _EmptyStateIconOnly(),
            20.verticalSpace,
            Text(
              'login_to_view_bookings'.tr(),
              textAlign: TextAlign.center,
              style: AppText.semibold16.copyWith(color: colors.textPrimary),
            ),
            20.verticalSpace,
            GestureDetector(
              onTap: () => context.router.replaceAll([LoginRoute()]),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(48.r),
                ),
                child: Text(
                  'login_button'.tr(),
                  style: AppText.semibold14.copyWith(color: colors.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The circular icon badge of [_EmptyState], reused by [_LoginPrompt].
class _EmptyStateIconOnly extends StatelessWidget {
  const _EmptyStateIconOnly();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: 80.w,
      height: 80.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Assets.icons.coupons.icFiles.svg(
        width: 36.w,
        height: 36.w,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(
          colors.primary.withValues(alpha: 0.5),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Shimmer.fromColors(
      baseColor: colors.surface,
      highlightColor: colors.canvas,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          width: double.infinity,
          height: 150.h,
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 30.w, color: colors.error),
            ),
            16.verticalSpace,
            Text(
              'something_went_wrong'.tr(),
              textAlign: TextAlign.center,
              style: AppText.semibold16.copyWith(color: colors.textPrimary),
            ),
            16.verticalSpace,
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(48.r),
                ),
                child: Text(
                  'retry'.tr(),
                  style: AppText.semibold14.copyWith(color: colors.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
