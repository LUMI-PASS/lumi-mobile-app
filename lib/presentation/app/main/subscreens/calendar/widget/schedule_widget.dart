import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';

class ScheduleWidget extends StatefulWidget {
  const ScheduleWidget({super.key, required this.scheduleItem});

  final ScheduleItem? scheduleItem;

  @override
  State<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      width: 1.sw,
      decoration: BoxDecoration(
          color: context.colors.onPrimary,
          borderRadius: BorderRadius.circular(16.r)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (widget.scheduleItem?.status ?? "").s(14).c(context.colors.primary),
          8.kh,
          (widget.scheduleItem?.status ?? "").s(12).w(400),
          8.kh,
          Row(
            children: [
              DateFormat('HH:mm')
                  .format(widget.scheduleItem?.startTime ?? DateTime.now())
                  .s(12)
                  .c(context.colors.grey),
              4.kw,
              Badge(
                backgroundColor: context.colors.grey,
              ),
              4.kw,
              (widget.scheduleItem?.status ?? "").s(12).c(context.colors.grey),
            ],
          ),
          12.kh,
          (widget.scheduleItem?.status ?? "").s(12).w(400),
          16.kh,
          CommonButton.elevated(text: "Confirm the class")
        ],
      ),
    );
  }
}
