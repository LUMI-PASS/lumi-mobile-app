import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF3C3E56),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Theme.of(context).primaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Assets.icons.card.svg(
                    width: 30.w,
                    height: 25.h,
                  ),
                  Assets.icons.circles.svg(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 15, top: 15),
            child: "5698    56254    6786    9979".s(16).w(600).c(Theme.of(context).cardColor),
          ),
          34.kh,
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 15, bottom: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    "Card Holder".s(12).w(500).c(Theme.of(context).cardColor),
                    "Name Here".s(17).w(600).c(Theme.of(context).cardColor)
                  ],
                ),
                Assets.icons.mastercard.svg(
                  width: 50.w,
                  height: 50.h,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
