import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/widget/empty_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/widget/schedule_widget.dart';
import 'package:shimmer/shimmer.dart';

import 'cubit/schedule_cubit.dart';
import 'cubit/schedule_state.dart';

@RoutePage()
class CalendarPage
    extends BasePage<ScheduleCubit, ScheduleBuildable, ScheduleListenable> {
  @override
  void init(BuildContext context) {
    context.read<ScheduleCubit>().getSchedule();
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
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -40,
            right: -60,
            child: Opacity(
              opacity: 0.15,
              child: Assets.icons.background.misc2.svg(
                width: 280.w,
                height: 280.w,
                colorFilter: ColorFilter.mode(
                  context.colors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.only(
              right: 24.w,
              left: 24.w,
              top: (MediaQuery.of(context).viewPadding.top + 12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                'schedule_title'.tr().s(20).w(600),
                16.kh,
                if (state.isLoading)
                  Expanded(child: _ScheduleShimmer())
                else if ((state.homeModel ?? []).isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.event_note_rounded,
                              size: 40.w,
                              color: context.colors.primary.withOpacity(0.4),
                            ),
                          ),
                          20.kh,
                          'schedule_title'.tr()
                              .s(18)
                              .w(600)
                              .c(Colors.black),
                          8.kh,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.w),
                            child: Text(
                              'booked_classes_appear_here'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return ScheduleWidget(
                          scheduleItem: (state.homeModel ?? [])[index],
                        );
                      },
                      itemCount: (state.homeModel ?? []).length,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          width: double.infinity,
          height: 160.h,
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 80.w, height: 16.h, color: Colors.white),
                SizedBox(height: 12.h),
                Container(width: 150.w, height: 14.h, color: Colors.white),
                SizedBox(height: 12.h),
                Container(width: 120.w, height: 12.h, color: Colors.white),
                SizedBox(height: 12.h),
                Container(width: 180.w, height: 12.h, color: Colors.white),
                const Spacer(),
                Container(
                  width: double.infinity,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
