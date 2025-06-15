import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileItem extends StatelessWidget {
  final SvgPicture image;
  final String labelText;
  final VoidCallback onTap;

  const ProfileItem({
    required this.image,
    required this.labelText,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: ChessColors.transparent,
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: ChessColors.greyG900,
                borderRadius: ChessRadius.radiusSm,
              ),
              child: image,
            ),
            const SizedBox(width: 12),
            Text(
              labelText,
              style: context.textTheme.bodyMedium.copyWith(
                color: ChessColors.greyG10,
              ),
            ),
            const Spacer(),
            ChessUiKitAssets.icons.general.chevronRight.svg(
              colorFilter: const ColorFilter.mode(
                ChessColors.greyG20,
                BlendMode.srcIn,
              ),
            )
          ],
        ),
      ),
    );
  }
}
