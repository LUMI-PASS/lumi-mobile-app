import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/feature/home/presentation/widget/companies_card_widget.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'home_items_group.dart';

class CompaniesGroup extends StatelessWidget {
  const CompaniesGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeItemsGroup(
      title: 'Top kompaniyalar',
      onViewAllTap: () => context.router.push(const CoursesRoute()),
      body: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) => CompaniesCard(index: index),
        ),
      ),
    );
  }
}
