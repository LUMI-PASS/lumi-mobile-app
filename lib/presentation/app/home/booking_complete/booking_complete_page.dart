import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';

import '../../../../common/widget/common_button.dart';

@RoutePage()
class BookingCompletePage extends StatefulWidget {
  const BookingCompletePage({super.key});

  @override
  State<BookingCompletePage> createState() => _BookingCompletePageState();
}

class _BookingCompletePageState extends State<BookingCompletePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            (MediaQuery.of(context).viewPadding.top.toInt()).kh,
            12.kh,
            Row(
              children: [
                Container(
                  width: 45.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: context.colors.onPrimary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Center(
                    child: Icon(CupertinoIcons.left_chevron),
                  ),
                )
              ],
            ),
            112.kh,
            Container(
                width: 115.w,
                height: 115.h,
                decoration: BoxDecoration(
                    color: context.colors.primary, shape: BoxShape.circle),
                child: const Center(
                    child: Icon(
                  CupertinoIcons.check_mark,
                  color: Colors.white,
                  size: 30,
                ))),
            16.kh,
            "Booking Complete".s(20).w(700),
            12.kh,
            "Your booking was successful! \nsee you at the class "
                .s(14)
                .w(500)
                .c(context.colors.title)
                .a(TextAlign.center),
            Spacer(),
            CommonButton.elevated(
              text: "Go to schedule",
              onPressed: () {
                context.router.popUntil((route) => route.isFirst);
              },
            ),
            16.kh,
            CommonButton.elevated(
              text: "Discover more classes",
              onPressed: () =>
                  context.router.popUntil((route) => route.isFirst),
            ),
            24.kh,
          ],
        ),
      ),
    );
  }
}
