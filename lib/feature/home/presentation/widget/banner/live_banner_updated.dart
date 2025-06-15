import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class EventsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Jonli efirlar",
              style: context.textTheme.title2Regular.copyWith(
                color: ChessColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FeaturedEventCard(),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ChessColors.primaryDefault.withOpacity(0.2),
            ChessColors.greyG800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: ChessRadius.radiusLg,
        border: Border.all(
          color: ChessColors.primaryDefault.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ChessColors.primaryDefault,
                  borderRadius: ChessRadius.radiusSm,
                ),
                child: Text(
                  "Featured event",
                  style: TextStyle(
                    color: ChessColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.bookmark_border,
                color: ChessColors.greyG300,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "G'oyani tasdiqlash va birinchi mijozlarni topish",
            style: context.textTheme.title1Regular.copyWith(
              color: ChessColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Thursday, May 23, 2025 - 4:00 PM PST",
            style: context.textTheme.bodyMedium.copyWith(
              color: ChessColors.greyG300,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(
                Icons.play_circle_filled,
                color: ChessColors.primaryDefault,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                "Live Event",
                style: TextStyle(
                  color: ChessColors.primaryDefault,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Text(
                "45 ishtirokchi",
                style: TextStyle(
                  color: ChessColors.greyG400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
