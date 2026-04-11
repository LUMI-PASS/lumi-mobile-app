import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
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

  bool get _isPopular => tariff.coins == 120;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container3d(
          onTap: onTap,
          padding: EdgeInsets.zero,
          backgroundColor: isSelected
              ? primary.withOpacity(0.1)
              : context.colors.onPrimary,
          borderColor: isSelected
              ? primary
              : _isPopular
                  ? primary.withOpacity(0.4)
                  : Colors.grey.shade200,
          borderWidth: isSelected || _isPopular ? 2 : 1,
          borderRadius: BorderRadius.circular(16.r),
          depth: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top banner with package title
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.r),
                    topLeft: Radius.circular(16.r),
                  ),
                  color:primary,
                ),
                child: Center(
                  child: (tariff.title ?? '')
                      .s(12)
                      .w(700)
                      .c(Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    8.kh,
                    Row(
                      children: [
                        "${tariff.coins}".w(700).s(20),
                        4.kw,
                        Assets.icons.coinLumi.image(width: 24.w, height: 24.h),
                      ],
                    ),
                    10.kh,
                    Text(
                      "${(tariff.price ?? 0).toString().toFormattedPrice()} so'm",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                    6.kh,
                  ],
                ),
              ),
            ],
          ),
        ),
        // Popular badge - ribbon style
        if (_isPopular)
          Positioned(
            top: -1,
            left: -1,
            child: Container(
              padding: EdgeInsets.fromLTRB(6.w, 2.h, 10.w, 2.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      size: 11.w, color: Colors.white),
                  2.kw,
                  Text(
                    'TOP',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
