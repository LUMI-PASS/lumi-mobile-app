import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class DiscussionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ChessColors.greyG800.withOpacity(0.6),
        borderRadius: ChessRadius.radiusMd,
        border: Border.all(
          color: ChessColors.primaryDefault.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: ChessColors.primaryDefault.withOpacity(0.3),
                child: Text(
                  "JT",
                  style: TextStyle(
                    color: ChessColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Javohir Tuxtamishev",
                      style: context.textTheme.bodyMedium.copyWith(
                        color: ChessColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Startup asoschilar jamiyati",
                      style: context.textTheme.bodyMedium.copyWith(
                        color: ChessColors.greyG400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "2s",
                style: TextStyle(
                  color: ChessColors.greyG400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Qanday qilib birinchi 100 mijozni topish mumkin? O'z tajribangizni ulashing",
            style: context.textTheme.bodyMedium.copyWith(
              color: ChessColors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              _InteractionButton(Icons.thumb_up_outlined, "12"),
              SizedBox(width: 16),
              _InteractionButton(Icons.chat_bubble_outline, "8"),
              SizedBox(width: 16),
              _InteractionButton(Icons.share_outlined, "3"),
              Spacer(),
              Icon(
                Icons.bookmark_border,
                color: ChessColors.greyG400,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String count;

  const _InteractionButton(this.icon, this.count);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: ChessColors.greyG400,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: ChessColors.greyG400,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}