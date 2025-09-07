import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/widgets/base_box.dart';

class CategoryItemWidget extends StatelessWidget {
  final HomCategory? homeCategoryModel;

  const CategoryItemWidget({super.key, required this.homeCategoryModel});

  @override
  Widget build(BuildContext context) {
    return BaseBox(
        width: 150.w,
        height: 150.h,
        margin: EdgeInsets.only(left: 8.w),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16.r)),
              child: Assets.images.defaultImage.image(),
            ),
            8.kh,
            Flexible(
                child: (homeCategoryModel?.title ?? "")
                    .s(14)
                    .w(600)
                    .m(2)
                    .a(TextAlign.center)),
          ],
        ));
  }
}
