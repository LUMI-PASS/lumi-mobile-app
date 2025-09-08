import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          50.kh,
          Assets.images.empty.image(width: 120.w, height: 120.h),
          8.kh,
          (text ?? "Hech narsa topilmadi!").s(16).w(600).c(context.colors.primary),
        ],
      ),
    );
  }
}
