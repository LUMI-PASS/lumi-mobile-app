import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/common_button.dart';

class EmptyWidget extends StatefulWidget {
  const EmptyWidget({super.key});

  @override
  State<EmptyWidget> createState() => _EmptyWidgetState();
}

class _EmptyWidgetState extends State<EmptyWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        "There’s nothing here".s(22).w(600),
        12.kh,
        "Classes you have booked will appear here"
            .s(14)
            .c(context.colors.title)
            .w(400),
        24.kh,
        CommonButton.outlined(
            text: "Discover classes",
            backgroundColor: context.colors.onPrimary,
            borderColor: context.colors.primary,
            onPressed: () {},
            textColor: context.colors.primary)
      ],
    );
  }
}
