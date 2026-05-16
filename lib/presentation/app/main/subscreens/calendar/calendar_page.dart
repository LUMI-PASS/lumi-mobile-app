import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:shimmer/shimmer.dart';

import 'cubit/schedule_cubit.dart';
import 'cubit/schedule_state.dart';
import 'widget/schedule_widget.dart';

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
    context.read<ScheduleCubit>().refreshSilently();
    super.onFocusGained(context);
  }

  bool get _showLoginPrompt {
    final hasRealToken =
        getIt<Storage>().tokens.call()?.access != null;
    return RemoteConfigService.instance.isInReview && !hasRealToken;
  }

  @override
  Widget builder(BuildContext context, ScheduleBuildable state) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF5),
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

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt({required this.onLogin});
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              bottom: 12.h,
            ),
            child: Text(
              'tab_bookings'.tr(),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0E0C2B),
                letterSpacing: -0.3,
              ),
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
                        color: primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.receipt_long_rounded,
                          size: 40.w, color: primary.withOpacity(0.4)),
                    ),
                    20.kh,
                    'login_to_view_bookings'
                        .tr()
                        .s(15)
                        .w(600)
                        .c(const Color(0xFF1E293B)),
                    20.kh,
                    GestureDetector(
                      onTap: onLogin,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 32.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Text(
                          'login_button'.tr(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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

class _CalendarBody extends StatefulWidget {
  const _CalendarBody({required this.state, required this.onRefresh});

  final ScheduleBuildable state;
  final Future<void> Function() onRefresh;

  @override
  State<_CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<_CalendarBody> {
  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0E0C2B),
              letterSpacing: -0.3,
            ),
          ),
        ),
        Expanded(
          child: state.isLoading
              ? _BookingsShimmer()
              : Builder(builder: (context) {
                  // Show paid bookings with future dates AND cancelled
                  // bookings that haven't happened yet. Hide past cancelled
                  // and pending (unpaid) orders.
                  final filtered = state.orders
                      .where((o) =>
                          (o.isPaid || o.isCanceled) && o.hasFutureTicket)
                      .toList();
                  if (filtered.isEmpty) return const _EmptyBookings();
                  return RefreshIndicator(
                    color: const Color(0xFF6C4EF2),
                    onRefresh: widget.onRefresh,
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h + 64.0 + MediaQuery.of(context).viewPadding.bottom),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: BookingCard(order: filtered[index]),
                        );
                      },
                    ),
                  );
                }),
        ),
      ],
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE8FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 40.w,
              color: Color(0xFF6C4EF2).withOpacity(0.5),
            ),
          ),
          20.kh,
          'no_bookings_yet'.tr().s(18).w(600).c(Colors.black),
          8.kh,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'booked_classes_appear_here'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          width: double.infinity,
          height: 150.h,
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}
