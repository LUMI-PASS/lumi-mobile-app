import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/pill_filter_chip.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/widget/schedule_widget.dart';
import 'package:shimmer/shimmer.dart';

/// Profile → My Bookings. [PillFilterChip]s split the order list into Active
/// (paid/cancelled with a future ticket date) and Past (everything else). Uses
/// the same [BookingCard] and chips the Bookings tab renders.
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
  bool _isActive(UserOrder o) => (o.isPaid || o.isCanceled) && o.hasFutureTicket;

  bool get _hasRealToken => getIt<Storage>().tokens.call()?.access != null;

  bool get _showLoginPrompt =>
      RemoteConfigService.instance.isInReview && !_hasRealToken;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final visible = _orders.where((o) => !o.isPending).toList();
    final active = visible.where(_isActive).toList();
    final past = visible.where((o) => !_isActive(o)).toList();

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: BaseAppBar(title: 'my_bookings'.tr()),
      body: _showLoginPrompt
          ? const _LoginPrompt()
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
                  child: Row(
                    children: [
                      PillFilterChip(
                        label: '${'active_bookings'.tr()} (${active.length})',
                        selected: _position < 0.5,
                        onTap: () => _select(0),
                      ),
                      SizedBox(width: 8.w),
                      PillFilterChip(
                        label: '${'past_bookings'.tr()} (${past.length})',
                        selected: _position >= 0.5,
                        onTap: () => _select(1),
                      ),
                    ],
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
                                _OrdersList(orders: active, onRefresh: _load),
                                _OrdersList(orders: past, onRefresh: _load),
                              ],
                            ),
                ),
              ],
            ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.orders, required this.onRefresh});

  final List<UserOrder> orders;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return RefreshIndicator(
      color: colors.primary,
      backgroundColor: colors.surface,
      onRefresh: onRefresh,
      child: orders.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 120.h),
                const _EmptyState(),
              ],
            )
          : ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (_, i) => BookingCard(order: orders[i]),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Assets.images.mascot.mascotCalendar.image(
          width: 160.w,
          height: 160.w,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
        16.verticalSpace,
        Text(
          'no_bookings_yet'.tr(),
          textAlign: TextAlign.center,
          style: AppText.semibold16.copyWith(color: colors.textPrimary),
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
                padding:
                    EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
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
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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
