import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class ChessDurationInfo extends StatelessWidget {
  final int videoCount;
  final int duration;

  const ChessDurationInfo({
    required this.videoCount,
    required this.duration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildDurationWidget(
          context,
          icon: ChessUiKitAssets.icons.course.play,
          value: videoCount.toString(),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.circle,
          size: 4,
          color: ChessColors.greyG200,
        ),
        const SizedBox(width: 4),
        _buildDurationWidget(
          context,
          icon: ChessUiKitAssets.icons.course.clock,
          value: duration.formatDuration,
        ),
      ],
    );
  }

  Widget _buildDurationWidget(
    BuildContext context, {
    required SvgGenImage icon,
    required String value,
  }) {
    return Row(
      children: [
        icon.svg(
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            ChessColors.greyG30,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: context.textTheme.footnoteRegular.copyWith(
            color: ChessColors.greyG30,
          ),
        )
      ],
    );
  }
}
