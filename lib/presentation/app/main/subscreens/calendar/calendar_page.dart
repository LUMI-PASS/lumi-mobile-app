import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/pill_filter_chip.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
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
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
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
  /// Course enrolments and one-off class bookings share one list.
  List<UserOrder> _bookable() => widget.state.orders
      .where((o) => o.isActivityOrder && (o.isPaid || o.isCanceled))
      .toList();

  List<UserOrder> _applyFilter(List<UserOrder> base) {
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

  /// The list, split under headings.
  ///
  /// "All" is the default and was one undifferentiated stream in which a class
  /// finished last spring sat flush against one happening tomorrow. Splitting
  /// it says which is which without costing the reader a second tap on the
  /// chips. Under a chip that has already narrowed to one of the two, the
  /// heading would only repeat the chip, so it is left off.
  List<Widget> _groups(List<UserOrder> orders) {
    if (_filter != _BookingFilter.all) {
      return [for (final o in orders) BookingCard(order: o)];
    }
    final live = orders
        .where((o) => o.effectiveDisplayStatus == 'active')
        .toList();
    final done = orders
        .where((o) => o.effectiveDisplayStatus != 'active')
        .toList();
    return [
      if (live.isNotEmpty) ...[
        _SectionLabel('filter_active'.tr()),
        for (final o in live) BookingCard(order: o),
      ],
      if (done.isNotEmpty) ...[
        if (live.isNotEmpty) 8.kh,
        _SectionLabel('filter_completed'.tr()),
        for (final o in done) BookingCard(order: o),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = widget.state;
    final filtered = _applyFilter(_bookable());

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
              PillFilterChip(
                label: 'filter_all'.tr(),
                selected: _filter == _BookingFilter.all,
                onTap: () => setState(() => _filter = _BookingFilter.all),
              ),
              8.kw,
              PillFilterChip(
                label: 'filter_active'.tr(),
                selected: _filter == _BookingFilter.active,
                onTap: () => setState(() => _filter = _BookingFilter.active),
              ),
              8.kw,
              PillFilterChip(
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
              : filtered.isEmpty
                  ? const _EmptyBookings()
                  : RefreshIndicator(
                      color: AppColors.brandPurple,
                      onRefresh: widget.onRefresh,
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          16.w,
                          4.h,
                          16.w,
                          20.h +
                              64.0 +
                              MediaQuery.of(context).viewPadding.bottom,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: _groups(filtered),
                      ),
                    ),
        ),
      ],
    );
  }
}

/// A heading over a run of cards — the same 18/bold muted label the profile
/// screen groups its sections with, so the two tabs read as one system.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
      child: Text(
        text,
        style: AppText.bold18.copyWith(color: context.colors.textSecondary),
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onLogin});
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.images.mascot.mascotCalendar.image(
            width: 160.w,
            height: 160.w,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
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
    final c = context.colors;
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
