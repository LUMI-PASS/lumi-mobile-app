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
        margin: EdgeInsets.only(left: 8.w),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(16.r)),
              child: Assets.images.defaultImage
                  .image(width: 100.w, height: 80.h, fit: BoxFit.fill),
            ),
            8.kh,
            (homeCategoryModel?.title ?? "").s(12).w(600),
          ],
        ));
  }
}
