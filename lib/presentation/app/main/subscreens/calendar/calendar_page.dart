import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';

import 'cubit/schedule_cubit.dart';
import 'cubit/schedule_state.dart';
import 'widget/schedule_widget.dart';

/// The three booking filters shown as chips (Figma 96-3204).
enum _BookingFilter { all, active, completed }

/// The "Bookings" tab (originally named Calendar — the class name is kept so
/// the generated router doesn't need to be re-emitted).
@RoutePage()
class CalendarPage
    extends BasePage<ScheduleCubit, ScheduleBuildable, ScheduleListenable> {
  @override
  void init(BuildContext context) {
    context.read<ScheduleCubit>().loadBookings();
    super.init(context);
  }

  @override
  void onFocusGained(BuildContext context) {
    context.read<ScheduleCubit>().refreshIfLanguageChanged();
    super.onFocusGained(context);
  }

  bool get _showLoginPrompt {
    final hasRealToken = getIt<Storage>().tokens.call()?.access != null;
    return RemoteConfigService.instance.isInReview && !hasRealToken;
  }

  @override
  Widget builder(BuildContext context, ScheduleBuildable state) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.bg,
      body: _showLoginPrompt
          ? _LoginPrompt(
              onLogin: () => context.router.replaceAll([LoginRoute()]),
            )
          : _CalendarBody(
              state: state,
              onRefresh: () => context.read<ScheduleCubit>().refreshSilently(),
            ),
    );
  }
}

class _CalendarBody extends StatefulWidget {
  const _CalendarBody({required this.state, required this.onRefresh});

  final ScheduleBuildable state;
  final Future<void> Function() onRefresh;

  @override
  State<_CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<_CalendarBody> {
  _BookingFilter _filter = _BookingFilter.all;

  /// Paid or cancelled activity orders (subscriptions and unpaid drafts hidden).
  List _visibleOrders() {
    final base = widget.state.orders
        .where((o) => o.isActivityOrder && (o.isPaid || o.isCanceled))
        .toList();
    switch (_filter) {
      case _BookingFilter.all:
        return base;
      case _BookingFilter.active:
        return base
            .where((o) => o.effectiveDisplayStatus == 'active')
            .toList();
      case _BookingFilter.completed:
        const done = {'visited', 'missed', 'cancelled'};
        return base
            .where((o) => done.contains(o.effectiveDisplayStatus))
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final state = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewPadding.top + 16.h,
            left: 16.w,
            right: 16.w,
            bottom: 12.h,
          ),
          child: Text(
            'tab_bookings'.tr(),
            style: AppText.heading20.copyWith(color: c.textPrimary),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              _FilterChip(
                label: 'filter_all'.tr(),
                selected: _filter == _BookingFilter.all,
                onTap: () => setState(() => _filter = _BookingFilter.all),
              ),
              8.kw,
              _FilterChip(
                label: 'filter_active'.tr(),
                selected: _filter == _BookingFilter.active,
                onTap: () => setState(() => _filter = _BookingFilter.active),
              ),
              8.kw,
              _FilterChip(
                label: 'filter_completed'.tr(),
                selected: _filter == _BookingFilter.completed,
                onTap: () => setState(() => _filter = _BookingFilter.completed),
              ),
            ],
          ),
        ),
        12.kh,
        Expanded(
          child: state.isLoading
              ? const _BookingsShimmer()
              : Builder(builder: (context) {
                  final filtered = _visibleOrders();
                  if (filtered.isEmpty) return const _EmptyBookings();
                  return RefreshIndicator(
                    color: AppColors.brandPurple,
                    onRefresh: widget.onRefresh,
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        16.w,
                        4.h,
                        16.w,
                        20.h + 64.0 + MediaQuery.of(context).viewPadding.bottom,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          BookingCard(order: filtered[index]),
                    ),
                  );
                }),
        ),
      ],
    );
  }
}

/// A pill filter chip — selected shows the brand blue→purple gradient, otherwise
/// a muted surface fill (Figma 96-3204).
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.indigo : null,
          color: selected ? null : c.surface,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Text(
          label,
          style: AppText.semibold12.copyWith(
            color: selected ? Colors.white : c.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onLogin});
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w, bottom: 12.h),
            child: Text(
              'tab_bookings'.tr(),
              style: AppText.heading20.copyWith(color: c.textPrimary),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: AppColors.brandPurple.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.receipt_long_rounded,
                          size: 40.w, color: AppColors.brandPurple),
                    ),
                    20.kh,
                    Text(
                      'login_to_view_bookings'.tr(),
                      textAlign: TextAlign.center,
                      style: AppText.medium16.copyWith(color: c.textPrimary),
                    ),
                    20.kh,
                    GestureDetector(
                      onTap: onLogin,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          gradient: AppGradients.brand,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Text(
                          'login_button'.tr(),
                          style:
                              AppText.medium16.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.brandPurple.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded,
                size: 40.w, color: AppColors.brandPurple),
          ),
          20.kh,
          Text('no_bookings_yet'.tr(),
              style: AppText.bold18.copyWith(color: c.textPrimary)),
          8.kh,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'booked_classes_appear_here'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular14.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingsShimmer extends StatelessWidget {
  const _BookingsShimmer();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        width: double.infinity,
        height: 200.h,
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}
