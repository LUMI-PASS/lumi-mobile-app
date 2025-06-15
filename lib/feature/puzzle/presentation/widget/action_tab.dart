import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActionTab extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback? onTap;
  final Color? color;

  const ActionTab({
    required this.icon,
    required this.title,
    this.onTap,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final actionTabColor =
        onTap != null ? ChessColors.greyG200 : ChessColors.greyG50;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                color ?? actionTabColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: context.textTheme.caption2Semibold.copyWith(
                color: actionTabColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
