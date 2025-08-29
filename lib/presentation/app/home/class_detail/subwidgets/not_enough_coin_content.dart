import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/pocket_widget.dart';

class NotEnoughCoinContent extends StatefulWidget {
  const NotEnoughCoinContent({super.key});

  @override
  State<NotEnoughCoinContent> createState() => _NotEnoughCoinContentState();
}

class _NotEnoughCoinContentState extends State<NotEnoughCoinContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PocketWidget(),
            PocketWidget(),
          ],
        ),
        16.kh,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PocketWidget(),
            PocketWidget(),
          ],
        ),
      ],
    );
  }
}
