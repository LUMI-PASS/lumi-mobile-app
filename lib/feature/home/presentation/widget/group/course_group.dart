import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/feature/home/data/model/afisha/afisha_data.dart';
import 'package:founders_academy/feature/home/presentation/widget/afisha_widget.dart';
import 'package:founders_academy/feature/home/presentation/widget/course_widget.dart';
import 'package:founders_academy/feature/home/presentation/widget/group/home_items_group.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class CourseGroup extends StatelessWidget {
  const CourseGroup({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HomeItemsGroup(
      title: 'Ommabop kurslar',
      onViewAllTap: () => context.router.push(const CoursesRoute()),
      body: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) => CourseCard(index: index),
        ),
      ),
    );
  }
}
