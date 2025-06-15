import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/feature/courses/data/model/lesson/lesson_data.dart';
import 'package:founders_academy/feature/courses/data/model/module/module_data.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class LessonExpansionTile extends StatelessWidget {
  final int moduleIndex;
  final ModuleData module;
  final VoidCallback onLessonUpdated;

  const LessonExpansionTile({
    required this.moduleIndex,
    required this.module,
    required this.onLessonUpdated,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String fullTitle = "${moduleIndex + 1}. ${module.name}";
    final List<LessonData>? moduleLessons = module.lessons;
    final router = context.router;

    return ExpansionTile(
      initiallyExpanded: module.isExpanded,
      tilePadding: EdgeInsets.zero,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fullTitle,
            style: context.textTheme.headlineSemibold.copyWith(color: ChessColors.white),
          ),
          const SizedBox(height: 8),
          ChessDurationInfo(
            videoCount: moduleLessons?.length ?? 0,
            duration: module.duration ?? 0,
          )
        ],
      ),
      shape: const Border(),
      children: moduleLessons != null
          ? List.generate(
              moduleLessons.length,
              (index) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moduleLessons[index].name,
                    style: context.textTheme.headlineSemibold.copyWith(
                      color: ChessColors.greyG20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _WatchButton(
                    type: moduleLessons[index].status,
                    onTap: () async {
                      await router.push(
                        LessonDetailsRoute(
                          lesson: moduleLessons[index],
                          module: module,
                        ),
                      );

                      onLessonUpdated();
                    },
                  ),
                  const Divider(color: ChessColors.greyG30),
                ],
              ),
            )
          : [const SizedBox.expand()],
    );
  }
}

class _WatchButton extends StatelessWidget {
  final LessonStatus type;
  final VoidCallback onTap;
  const _WatchButton({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: type != LessonStatus.inactive ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _borderColor),
          borderRadius: ChessRadius.radiusXs,
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChessUiKitAssets.icons.course.playCircle.svg(
              colorFilter: ColorFilter.mode(_iconColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              "Darsni ko'rish",
              style: context.textTheme.footnoteMedium.copyWith(
                color: _titleColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Color get _borderColor {
    switch (type) {
      case LessonStatus.completed:
        return ChessColors.successDefault;
      default:
        return ChessColors.greyG40;
    }
  }

  Color get _titleColor {
    switch (type) {
      case LessonStatus.inactive:
        return ChessColors.greyG20;
      default:
        return ChessColors.greyG90;
    }
  }

  Color get _iconColor {
    switch (type) {
      case LessonStatus.inactive:
        return ChessColors.greyG20;
      case LessonStatus.active:
        return ChessColors.greyG90;
      case LessonStatus.completed:
        return ChessColors.successDefault;
    }
  }
}
