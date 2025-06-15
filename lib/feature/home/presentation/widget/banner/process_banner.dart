import 'package:lumi_pass/feature/base_url/app_base_url_cubit.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_state.dart';
import 'package:lumi_pass/feature/courses/data/model/course/course_data.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProcessBanner extends StatelessWidget {
  final CourseData course;
  const ProcessBanner({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0).copyWith(left: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: ChessRadius.radiusSm,
                child: ChessNetworkImage(
                  imageUrl: course.icon,
                  fit: BoxFit.fitHeight,
                  width: 80,
                  height: 80,
                  baseUrl: state.baseUrl,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _CaptionWidget(course),
                    const SizedBox(height: 8),
                    ChessDurationInfo(
                      videoCount: course.lessonsCount ?? 0,
                      duration: course.duration ?? 0,
                    ),
                    const SizedBox(height: 8),
                    ChessProgressIndicator(value: course.progress),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _CaptionWidget extends StatelessWidget {
  final CourseData course;
  const _CaptionWidget(this.course);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.name,
                style: context.textTheme.title3Bold,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                course.shortDescription,
                style: context.textTheme.footnoteRegular.copyWith(
                  color: ChessColors.greyG200,
                ),
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
        ChessUiKitAssets.icons.general.chevronRight.svg()
      ],
    );
  }
}
