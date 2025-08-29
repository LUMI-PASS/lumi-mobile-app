import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/widgets/base_box.dart';

class ClassItemWidget extends StatelessWidget {
  const ClassItemWidget({super.key, required this.homClass, this.width});

  final HomClass? homClass;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return BaseBox(
        onTap: () => context.router
            .push(ClassDetailRoute(classModel: homClass ?? HomClass())),
        width: width ?? 1.sw * 0.8,
        margin: EdgeInsets.only(right: 8.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16.r)),
              child: Assets.images.defaultImage.image(
                  width: (width ?? 1.sw * 0.8) - 32.w,
                  height: 100.h,
                  fit: BoxFit.fill),
            ),
            8.kh,
            Row(
              children: [
                (homClass?.category ?? "").s(12).w(500),
                8.kw,
                Badge(
                  backgroundColor: context.colors.grey,
                ),
                8.kw,
                "${homClass?.minAge ?? 0}-${homClass?.maxAge ?? 0} y.o"
                    .s(12)
                    .w(400)
                    .c(context.colors.grey)
              ],
            ),
            12.kh,
            (homClass?.title ?? "").s(14).w(400),
            8.kh,
            (homClass?.branch?.title ?? "").s(400).c(context.colors.grey).s(12),
            8.kh,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.icons.location.svg(),
                    4.kw,
                    (homClass?.branch?.address ?? "")
                        .s(12)
                        .w(400)
                        .c(context.colors.grey),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFF3F5FF),
                      borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      (homClass?.price ?? 0).toString().s(10).w(600),
                      Assets.icons.coinLumi.image(width: 17.w, height: 17.h),
                    ],
                  ),
                )
              ],
            )
          ],
        ));
  }
}
