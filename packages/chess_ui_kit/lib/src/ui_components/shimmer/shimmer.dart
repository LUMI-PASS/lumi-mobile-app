import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AfishaShimmer extends StatelessWidget {
  const AfishaShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: ChessColors.greyG30,
        highlightColor: ChessColors.greyG10,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: ChessColors.greyG40,
              ),
              height: 64,
              width: 64,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: ChessRadius.radiusSm,
                      color: ChessColors.greyG50,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 24,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: ChessRadius.radiusSm,
                        color: ChessColors.greyG50,
                      ),
                      height: 12,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GrandmasterGroupShimmer extends StatelessWidget {
  const GrandmasterGroupShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ChessColors.greyG30,
      highlightColor: ChessColors.greyG10,
      child: Container(
        height: 200,
        width: 140,
        decoration: BoxDecoration(
          borderRadius: ChessRadius.radiusSm,
          color: ChessColors.greyG40,
        ),
      ),
    );
  }
}

class ReviewMatchesGroupShimmer extends StatelessWidget {
  const ReviewMatchesGroupShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ChessColors.greyG30,
      highlightColor: ChessColors.greyG10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: ChessRadius.radiusSm,
              color: ChessColors.greyG50,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: ChessRadius.radiusSm,
              color: ChessColors.greyG50,
            ),
            height: 12,
            width: 200,
          ),
        ],
      ),
    );
  }
}

class NewsGroupShimmer extends StatelessWidget {
  const NewsGroupShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: ChessColors.greyG30,
        highlightColor: ChessColors.greyG10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: ChessRadius.radiusSm,
                  color: ChessColors.greyG50,
                ),
                height: 120,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: ChessRadius.radiusSm,
                      color: ChessColors.greyG50,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: ChessRadius.radiusSm,
                      color: ChessColors.greyG50,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BookGroupShimmer extends StatelessWidget {
  const BookGroupShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: ChessColors.greyG30,
      highlightColor: ChessColors.greyG10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 280),
            decoration: BoxDecoration(
              borderRadius: ChessRadius.radiusSm,
              color: ChessColors.greyG50,
            ),
            height: 160,
            width: 108,
          ),
          const SizedBox(height: 12),
          Container(
            height: 12,
            width: 108,
            decoration: BoxDecoration(
              borderRadius: ChessRadius.radiusSm,
              color: ChessColors.greyG50,
            ),
          ),
        ],
      ),
    );
  }
}
