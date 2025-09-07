import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/data/api_model/tarifff/tariff_model.dart';

import '../../../../../common/gen/assets.gen.dart';

class PocketWidget extends StatelessWidget {
  final Tariff tariff;
  final bool isSelected;
  final VoidCallback onTap;

  const PocketWidget({
    super.key,
    required this.tariff,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (1.sw - 48.w) / 2,
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary.withOpacity(0.1) : context.colors.onPrimary,
          border: isSelected
              ? Border.all(color: context.colors.primary, width: 2)
              : null,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: (1.sw - 48.w) / 2,
                height: 20.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16.r),
                      topLeft: Radius.circular(16.r)
                  ),
                  color: isSelected ? context.colors.primary : context.colors.primary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    "${tariff.validDays} days"
                        .s(12)
                        .w(700)
                        .c(context.colors.onPrimary)
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    12.kh,
                    "${tariff.title}".s(12).w(700),
                    8.kh,
                    Row(
                      children: [
                        "${tariff.coins}".w(700).s(18),
                        Assets.icons.coinLumi.image(width: 24.w, height: 24.h),
                      ],
                    ),
                    12.kh,
                    Text(
                      "700.000 SOâ€™M",
                      style: TextStyle(
                          color: context.colors.grey,
                          decoration: TextDecoration.lineThrough
                      ),
                    ),
                    12.kh,
                    "${tariff.price.toString().toFormattedPrice()} SOâ€™M"
                        .s(13)
                        .w(700),
                    12.kh
                  ],
                ),
              ),
            ]
        ),
      ),
    );
  }
}