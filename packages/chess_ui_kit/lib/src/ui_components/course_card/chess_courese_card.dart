import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class ChessCourseCard extends StatelessWidget {
  final String name;
  final String shortDescription;
  final String imageIcon;
  final int lessonCount;
  final int duration;
  final bool isEnrolled;
  final VoidCallback onTap;
  final String baseUrl;
  final int? progressValue;

  const ChessCourseCard({
    required this.name,
    required this.shortDescription,
    required this.imageIcon,
    required this.lessonCount,
    required this.duration,
    required this.isEnrolled,
    required this.onTap,
    required this.baseUrl,
    this.progressValue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0).copyWith(left: 24),
        decoration: BoxDecoration(
          color: ChessColors.greyG800,
          borderRadius: ChessRadius.radiusMd,
          boxShadow: ChessShadows.shadowLg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: ChessRadius.radiusSm,
              child: ChessNetworkImage(
                imageUrl: imageIcon,
                fit: BoxFit.fitHeight,
                height: 80,
                width: 80,
                baseUrl: baseUrl,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _CaptionWidget(
                    name: name,
                    shortDescription: shortDescription,
                  ),
                  const SizedBox(height: 8),
                  ChessDurationInfo(
                    videoCount: lessonCount,
                    duration: duration,
                  ),
                  if (isEnrolled && progressValue != null) ...[
                    const SizedBox(height: 8),
                    ChessProgressIndicator(value: progressValue!),
                  ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _CaptionWidget extends StatelessWidget {
  final String name;
  final String shortDescription;

  const _CaptionWidget({required this.name, required this.shortDescription});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: context.textTheme.title3Bold
                      .copyWith(color: ChessColors.greyG20)),
              Text(
                shortDescription,
                style: context.textTheme.footnoteRegular.copyWith(
                  color: ChessColors.greyG30,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
        ChessUiKitAssets.icons.general.chevronRight
            .svg(color: ChessColors.white)
      ],
    );
  }
}
