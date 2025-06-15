import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/feature/home/data/model/afisha/afisha_data.dart';
import 'package:lumi_pass/feature/home/presentation/widget/afisha_widget.dart';
import 'package:lumi_pass/feature/home/presentation/widget/group/home_items_group.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class AfishaGroup extends StatelessWidget {
  final List<AfishaData> afishaList;

  const AfishaGroup({
    required this.afishaList,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HomeItemsGroup(
      title: 'Afisha',
      onViewAllTap: () => context.router.push(const AfishaListRoute()),
      body: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Divider(color: ChessColors.greyG30),
        ),
        itemCount: afishaList.length,
        itemBuilder: (context, index) {
          final afisha = afishaList[index];
          return AfishaWidget(
            afishaData: afisha,
          );
        },
      ),
    );
  }
}
