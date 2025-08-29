import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/common_button.dart';

import '../../../../../common/gen/assets.gen.dart';

class PocketWidget extends StatefulWidget {
  const PocketWidget({super.key});

  @override
  State<PocketWidget> createState() => _PocketWidgetState();
}

class _PocketWidgetState extends State<PocketWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: (1.sw - 48.w) / 2,
      decoration: BoxDecoration(
          color: context.colors.onPrimary,
          borderRadius: BorderRadius.circular(16.r)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: (1.sw - 48.w) / 2,
          height: 20.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(16.r),
                topLeft: Radius.circular(16.r)),
            color: context.colors.primary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ["12 days".s(12).w(700).c(context.colors.onPrimary)],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              12.kh,
              "Standart".s(12).w(700),
              8.kh,
              Row(
                children: [
                  "50".w(700).s(18),
                  Assets.icons.coinLumi.image(width: 24.w, height: 24.h),
                ],
              ),
              12.kh,
              Text(
                "700.000 SO’M",
                style: TextStyle(
                    color: context.colors.grey,
                    decoration: TextDecoration.lineThrough),
              ),
              12.kh,
              "500.000 SO’M".s(13).w(700),
              12.kh
            ],
          ),
        ),
      ]),
    );
  }
}
