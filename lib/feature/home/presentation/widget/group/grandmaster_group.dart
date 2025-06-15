import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/feature/home/data/model/grandmaster/grandmaster_data.dart';
import 'package:founders_academy/feature/home/presentation/widget/grandmaster_widget.dart';
import 'package:founders_academy/feature/home/presentation/widget/group/home_items_group.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:flutter/material.dart';

class GrandmasterGroup extends StatelessWidget {
  final List<GrandmasterData> grandmasterList;

  const GrandmasterGroup({
    required this.grandmasterList,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HomeItemsGroup(
      title: 'Qisqa videolar',
      onViewAllTap: () => context.router.push(const GrandmastersListRoute()),
      body: SizedBox(
        height: 200,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 24, right: 24),
          shrinkWrap: true,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemCount: grandmasterList.length,
          itemBuilder: (context, index) => GrandmasterWidget(
            grandmaster: grandmasterList[index],
          ),
        ),
      ),
    );
  }
}
