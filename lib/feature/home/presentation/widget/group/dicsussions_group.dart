import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/feature/home/data/model/news/news_data.dart';
import 'package:lumi_pass/feature/home/presentation/widget/dicucssions_widget.dart';
import 'package:lumi_pass/feature/home/presentation/widget/group/home_items_group.dart';
import 'package:lumi_pass/feature/home/presentation/widget/news_widget.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class DiscussionsGroup extends StatelessWidget {
  const DiscussionsGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HomeItemsGroup(
      title: 'Muhokamalar',
      onViewAllTap: () => context.router.push(const NewsListRoute()),
      body: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        ),
        itemCount: 2,
        itemBuilder: (context, index) {
          return DiscussionCard();
        },
      ),
    );
  }
}
