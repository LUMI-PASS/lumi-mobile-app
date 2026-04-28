import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
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

  @override
  Widget builder(BuildContext context, ScheduleBuildable state) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF5),
      body: _CalendarBody(
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
  int _tab = 0;

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
            bottom: 8.h,
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
        Padding(
          padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8FF),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TabPill(
                  label: 'Faol',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _TabPill(
                  label: 'Tarix',
                  selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: state.isLoading
              ? _BookingsShimmer()
              : Builder(builder: (context) {
                  final filtered = _tab == 0
                      ? state.orders
                          .where((o) => !o.isCanceled)
                          .toList()
                      : state.orders
                          .where((o) => o.isCanceled)
                          .toList();
                  if (filtered.isEmpty) return const _EmptyBookings();
                  return RefreshIndicator(
                    color: const Color(0xFF6C4EF2),
                    onRefresh: widget.onRefresh,
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
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

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: selected
              ? [
                  const BoxShadow(
                    color: Color(0x1A6C4EF2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: selected
                ? const Color(0xFF4A2FD4)
                : const Color(0xFF6B6899),
          ),
        ),
      ),
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
