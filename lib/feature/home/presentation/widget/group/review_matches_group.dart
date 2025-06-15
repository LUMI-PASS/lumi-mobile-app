import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/feature/home/data/model/review_matches/review_matches_data.dart';
import 'package:founders_academy/feature/home/presentation/widget/group/home_items_group.dart';
import 'package:founders_academy/feature/home/presentation/widget/review_matches_widget.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReviewMatchesGroup extends StatelessWidget {
  final List<ReviewMatchData> reviewMatchesList;

  const ReviewMatchesGroup({
    required this.reviewMatchesList,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HomeItemsGroup(
      title: 'Foydali videolar',
      onViewAllTap: () => context.router.push(const ReviewMatchesListRoute()),
      body: SizedBox(
        height: 144,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemCount: reviewMatchesList.length,
          itemBuilder: (context, index) => ReviewMatchWidget(
            reviewMatch: reviewMatchesList[index],
          ),
        ),
      ),
    );
  }
}
