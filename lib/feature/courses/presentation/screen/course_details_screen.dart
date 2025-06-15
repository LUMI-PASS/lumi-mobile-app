import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/core/logging/logger.dart';
import 'package:lumi_pass/di/get_it.dart';
import 'package:lumi_pass/feature/auth/data/data_source/token_data_source.dart';
import 'package:lumi_pass/feature/auth/data/data_source/user_data_source.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_cubit.dart';
import 'package:lumi_pass/feature/base_url/app_base_url_state.dart';
import 'package:lumi_pass/feature/courses/data/model/course/course_data.dart';
import 'package:lumi_pass/feature/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:lumi_pass/feature/courses/presentation/cubit/course_details/course_details_state.dart';
import 'package:lumi_pass/feature/courses/presentation/widget/lesson_expansion_tile.dart';
import 'package:lumi_pass/feature/courses/presentation/widget/payment_bottom_sheet.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/feature/home/presentation/screen/details_screen/book_details_screen.dart';

@RoutePage()
class CourseDetailsScreen extends StatefulWidget {
  final CourseData course;

  const CourseDetailsScreen({
    required this.course,
    super.key,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with WidgetsBindingObserver {
  late CourseDetailsCubit cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cubit = context.read<CourseDetailsCubit>(); // Store the Cubit once
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.course.isEnrolled
          ? null
          : setState(() {
              cubit.init(widget.course);
              context
                  .read<CourseDetailsCubit>()
                  .enrollToCourse(widget.course.id);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider<CourseDetailsCubit>(
                    create: (context) =>
                        getIt<CourseDetailsCubit>()..init(widget.course),
                    child: CourseDetailsScreen(course: widget.course),
                  ),
                ),
              );
            });
    }
  }

  Future<void> refreshContent(BuildContext context) async {
    final cubit = context.read<CourseDetailsCubit>();
    context.read<CourseDetailsCubit>().enrollToCourse(widget.course.id);
    await Future<void>.delayed(const Duration(seconds: 1), () {
      cubit.init(widget.course);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userDataSource = getIt<UserDataDataSource>();
    final tokenSource = getIt<TokenDataSource>();

    return BlocProvider(
      create: (context) => getIt<CourseDetailsCubit>()..init(widget.course),
      child: BlocListener<CourseDetailsCubit, CourseDetailsState>(
        listener: (context, state) {
          if (state is CourseDetailsEnrollSucceededState) {
            setState(() {});
            _showChessSnackBar(context, SnackBarType.success);
          }
          if (state is CourseDetailsEnrollFailedState) {
            //_showChessSnackBar(context, SnackBarType.error);
          }
        },
        child: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0.0,
                elevation: 0,
                leading: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: context.router.pop,
                  child: ChessUiKitAssets.icons.general.arrowLeft.svg(
                    fit: BoxFit.none,
                    color: ChessColors.white,
                  ),
                ),
              ),
              body: Builder(builder: (context) {
                widget.course.progress == 100
                    ? context
                        .read<CourseDetailsCubit>()
                        .getCertificate(widget.course.id)
                    : const SizedBox();
                if (state is CourseDetailsLoadingState) {
                  return const Center(child: ChessCircularProgressIndicator());
                }

                return RefreshIndicator(
                  backgroundColor: ChessColors.white,
                  color: ChessColors.primaryDefault,
                  onRefresh: () => refreshContent(context),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CourseHeader(
                          courseTitle: widget.course.name,
                          courseDescription: widget.course.shortDescription,
                          courseIcon: widget.course.icon,
                          lessonCount: widget.course.lessonsCount.toString(),
                          lessonDuration: widget.course.duration ?? 0,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Builder(builder: (context) {
                            return switch (state) {
                              CourseDetailsLoadingState() =>
                                const SizedBox.shrink(),
                              CourseDetailsErrorState() =>
                                const SizedBox.shrink(),
                              CourseDetailsLoadedState() => state.isEnrolled
                                  ? _ProgressWidget(value: state.progress)
                                  : ChessButton.primary(
                                      onPressed: () {
                                        // FirebaseAnalytics.instance.logEvent(
                                        //   name: 'course_buy_event',
                                        //   parameters: {
                                        //     'param1': 'value1',
                                        //     'param2': 123,
                                        //   },
                                        // ).then((value) {
                                        //   logger.e('Event successfully logged');
                                        // }).catchError((error) {
                                        //   logger
                                        //       .e('Failed to log event: $error');
                                        // });
                                        PaymentMethodDialog.show(
                                          context,
                                          (selectedPaymentMethod) {
                                            // Handle payment method selection
                                          },
                                          widget.course,
                                          userDataSource,
                                          tokenSource,
                                        );
                                      },
                                      label: "Kurs sotib olish",
                                    ),
                              CourseDetailsEnrollSucceededState() =>
                                const SizedBox.shrink(),
                              CourseDetailsEnrollFailedState() =>
                                const SizedBox.shrink(),
                            };
                          }),
                        ),
                        const SizedBox(height: 16),
                        _BodyContent(state, widget.course),
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

void _showChessSnackBar(BuildContext context, SnackBarType type) {
  IconData icon;
  String message;
  Color backgroundColor;
  switch (type) {
    case SnackBarType.success:
      icon = Icons.done;
      message = "Kursga muvaffaqiyatli yozildingiz";
      backgroundColor = ChessColors.successDefault;
      break;
    case SnackBarType.error:
      icon = Icons.error_outline;
      message = "Xato! Iltimos, qaytadan urinib ko'ring";
      backgroundColor = ChessColors.errorDefault;
      break;
  }

  final snackBar = ChessSnackBar(
    icon: icon,
    message: message,
    backgroundColor: backgroundColor,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar.getChessSnackBar);
}

class _HeaderContent extends StatelessWidget {
  final String imageUrl;
  const _HeaderContent(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final contentHeight = MediaQuery.sizeOf(context).height * .36;
    return BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
      builder: (context, state) {
        final baseUrl = state.baseUrl;

        return SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: contentHeight,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                top: 0,
                child: BackgroundWaveClipper.buildWave(
                  context,
                  height: contentHeight - 36,
                ),
              ),
              ClipRRect(
                borderRadius: ChessRadius.radiusSm,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width*0.6,
                  height: 307,
                  child: ChessNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    baseUrl: baseUrl,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CourseHeader extends StatefulWidget {
  final String courseTitle;
  final String courseDescription;
  final String courseIcon;
  final String lessonCount;
  final int lessonDuration;

  const _CourseHeader({
    required this.courseTitle,
    required this.courseDescription,
    required this.courseIcon,
    required this.lessonCount,
    required this.lessonDuration,
  });

  @override
  __CourseHeaderState createState() => __CourseHeaderState();
}

class __CourseHeaderState extends State<_CourseHeader> {
  bool isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0).copyWith(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
            builder: (context, state) {
              return _HeaderContent(widget.courseIcon);
            },
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            widget.courseTitle,
            style: context.textTheme.title3Bold.copyWith(
              color: ChessColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ChessUiKitAssets.icons.course.play.svg(
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  ChessColors.greyG20,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(widget.lessonCount),
              const SizedBox(width: 8),
              ChessUiKitAssets.icons.course.clock.svg(
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  ChessColors.greyG20,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(widget.lessonDuration.formatDuration),
            ],
          ),
          const SizedBox(height: 24),
          // Description
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: ChessRadius.radiusMd,
              color: ChessColors.greyG800,
              boxShadow: ChessShadows.shadowLg,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Kurs haqida",
                    style: context.textTheme.headlineSemibold.copyWith(
                      color: ChessColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.courseDescription,
                    style: context.textTheme.footnoteRegular.copyWith(
                      color: ChessColors.greyG20,
                    ),
                    maxLines: isDescriptionExpanded ? null : 3,
                    overflow: isDescriptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isDescriptionExpanded = !isDescriptionExpanded;
                      });
                    },
                    child: Text(
                      isDescriptionExpanded ? 'Qisqa' : 'Batafsil',
                      style: context.textTheme.subheadlineRegular.copyWith(
                        color: ChessColors.primaryDefault,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  final CourseDetailsState state;
  final CourseData courseData;

  const _BodyContent(
    this.state,
    this.courseData,
  );

  @override
  Widget build(BuildContext context) {
    final currentState = state;
    final cubit = context.read<CourseDetailsCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24).copyWith(bottom: 0),
          child: Text(
            "Bo'limlar",
            style: context.textTheme.bodyMedium,
          ),
        ),
        switch (currentState) {
          CourseDetailsLoadingState() => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: ChessCircularProgressIndicator(),
            ),
          CourseDetailsLoadedState() => currentState.moduleList.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: ChessColors.greyG800,
                    boxShadow: ChessShadows.shadowMd,
                    borderRadius: ChessRadius.radiusMd,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: currentState.moduleList.length,
                    itemBuilder: (_, index) {
                      final module = currentState.moduleList[index];

                      return LessonExpansionTile(
                        moduleIndex: index,
                        module: module,
                        onLessonUpdated: () => cubit.init(courseData),
                      );
                    },
                  ),
                ),
          CourseDetailsErrorState() => const SizedBox.shrink(),
          CourseDetailsEnrollSucceededState() =>
            throw Exception('Attempt to build screen on enroll succeed'),
          CourseDetailsEnrollFailedState() =>
            throw Exception('Attempt to build screen on enroll failed'),
        }
      ],
    );
  }
}

class _ProgressWidget extends StatelessWidget {
  final int value;
  const _ProgressWidget({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        boxShadow: ChessShadows.shadowLg,
        color: ChessColors.white,
        borderRadius: ChessRadius.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Text(
              "O'qish jarayoni",
              style: context.textTheme.subheadlineSemibold,
            ),
          ),
          ChessProgressIndicator(value: value)
        ],
      ),
    );
  }
}
