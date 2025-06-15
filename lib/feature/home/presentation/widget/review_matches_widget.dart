import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/core/logging/logger.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/home/data/model/review_matches/review_matches_data.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewMatchWidget extends StatelessWidget {
  final ReviewMatchData reviewMatch;
  final VoidCallback? onTap;

  const ReviewMatchWidget({
    required this.reviewMatch,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            onTap?.call();
            context.router.push(
              ReviewMatchDetailsRoute(id: reviewMatch.id),
            );
            FirebaseAnalytics.instance.logEvent(
              name: 'foydali_videolar_event',
              parameters: {
                'param1': 'value1',
                'param2': 123,
              },
            ).then((value) {
              logger.e('Event successfully logged');
            }).catchError((error) {
              logger.e('Failed to log event: $error');
            });
          },
          child: SizedBox(
            width: 160,
            child: Column(
              children: [
                SizedBox(
                  height: 92,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ChessNetworkImage(
                      imageUrl: reviewMatch.thumbnailUrl,
                      height: 92,
                      width: 160,
                      fit: BoxFit.cover,
                      baseUrl: state.baseUrl,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    reviewMatch.title,
                    style: context.textTheme.calloutMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
