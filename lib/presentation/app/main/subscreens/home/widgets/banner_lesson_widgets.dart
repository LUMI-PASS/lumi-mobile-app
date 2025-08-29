import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/widgets/base_box.dart';

class BannerLessonWidgets extends StatefulWidget {
  const BannerLessonWidgets({super.key, required this.homBanner});

  final HomUpcomingClass homBanner;

  @override
  State<BannerLessonWidgets> createState() => _BannerLessonWidgetsState();
}

class _BannerLessonWidgetsState extends State<BannerLessonWidgets> {
  @override
  Widget build(BuildContext context) {
    return BaseBox(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.homBanner.className ?? "").s(16).c(context.colors.primary),
            8.kh,
            (widget.homBanner.branchName ?? "").s(16),
            8.kh,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (DateFormat('HH:mm')
                        .format(widget.homBanner.startTime ?? DateTime.now()))
                    .toString()
                    .s(12)
                    .w(400)
                    .c(context.colors.title),
                8.kw,
                Badge(
                  backgroundColor: context.colors.grey,
                ),
                8.kw,
                (widget.homBanner.branchAddress ?? "")
                    .s(12)
                    .c(context.colors.title)
                    .w(400),
              ],
            ),
            8.kh,
            (widget.homBanner.branchAddress ?? "")
                .s(12)
                .c(context.colors.primary)
                .w(400),
            24.kh,
            CommonButton.elevated(
              text: "Confirm the class",
              backgroundColor: context.colors.primary.withOpacity(0.1),
              textColor: context.colors.primary,
            )
          ],
        ));
  }
}
