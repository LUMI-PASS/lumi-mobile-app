import 'package:flexobo/common/extensions/sizedbox_extensions.dart';
import 'package:flexobo/common/extensions/text_extensions.dart';
import 'package:flexobo/common/extensions/theme_extensions.dart';
import 'package:flexobo/common/gen/assets.gen.dart';
import 'package:flexobo/common/gen/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          50.kh,
          Assets.images.notFound.image(width: 120.w, height: 120.h),
          8.kh,
          Strings.notFound.s(16).w(600).c(context.colors.primary),
        ],
      ),
    );
  }
}
