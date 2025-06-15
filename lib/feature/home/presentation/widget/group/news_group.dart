import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/feature/home/data/model/news/news_data.dart';
import 'package:lumi_pass/feature/home/presentation/widget/group/home_items_group.dart';
import 'package:lumi_pass/feature/home/presentation/widget/news_widget.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class NewsGroup extends StatelessWidget {
  final List<NewsData> newsList;

  const NewsGroup({
    required this.newsList,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HomeItemsGroup(
      title: 'Yangiliklar',
      onViewAllTap: () => context.router.push(const NewsListRoute()),
      body: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
        ),
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          return EnhancedNewsWidget(newsData: newsList[index]);
        },
      ),
    );
  }
}
