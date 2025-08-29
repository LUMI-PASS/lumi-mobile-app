import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/widget/loading_view.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/widget/empty_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/widget/schedule_widget.dart';

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
  Widget builder(BuildContext context, ScheduleBuildable state) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          right: 24.w,
          left: 24.w,
          top: (MediaQuery.of(context).viewPadding.top + 12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            "Schedule".s(20).w(600),
            if (state.isLoading) const LoadingView(),
            ((state.homeModel ?? []).isEmpty && state.isLoading == false)
                ? Column(
                    children: [
                      150.kh,
                      const EmptyWidget(),
                    ],
                  )
                : Expanded(
                    child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return ScheduleWidget(
                        scheduleItem: (state.homeModel ?? [])[index],
                      );
                    },
                    itemCount: (state.homeModel ?? []).length,
                  ))
          ],
        ),
      ),
    );
  }
}
