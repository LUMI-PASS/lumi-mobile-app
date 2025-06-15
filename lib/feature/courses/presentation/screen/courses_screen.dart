import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/core/logging/logger.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:founders_academy/feature/courses/presentation/cubit/courses/courses_cubit.dart';
import 'package:founders_academy/feature/courses/presentation/cubit/courses/courses_state.dart';
import 'package:founders_academy/feature/courses/presentation/screen/course_details_screen.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CourseFilterType {
  myCourses,
  allCourses,
}

@RoutePage()
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with SingleTickerProviderStateMixin {
  CourseFilterType _selectedFilter = CourseFilterType.myCourses;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CoursesCubit>()..init(),
      child: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ChessColors.greyG900,
            body: switch (state) {
              CoursesLoadingState() => const ChessCircularProgressIndicator(),
              CoursesLoadedState() => _CoursesLoadedView(
                state: state,
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  _animationController.reset();
                  _animationController.forward();
                },
                fadeAnimation: _fadeAnimation,
              ),
              CoursesErrorState() => const SizedBox.expand()
            },
          );
        },
      ),
    );
  }
}

class _CoursesLoadedView extends StatelessWidget {
  final CoursesLoadedState state;
  final CourseFilterType selectedFilter;
  final Function(CourseFilterType) onFilterChanged;
  final Animation<double> fadeAnimation;

  const _CoursesLoadedView({
    required this.state,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CoursesCubit>();
    final filteredCourses = _getFilteredCourses();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          surfaceTintColor: ChessColors.greyG800,
          backgroundColor: ChessColors.greyG900,
          expandedHeight: 180,
          pinned: true,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 24, bottom: 80),
            centerTitle: false,
            title: Text(
              "Kurslar",
              style: context.textTheme.title3Bold.copyWith(
                color: ChessColors.white,
                shadows: [
                  Shadow(
                    color: ChessColors.greyG900.withOpacity(0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _CustomSegmentedControl(
                selectedFilter: selectedFilter,
                onFilterChanged: onFilterChanged,
              ),
            ),
          ),
        ),

        // Courses List
        BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
          builder: (context, baseUrlState) {
            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: filteredCourses.isEmpty
                  ? SliverToBoxAdapter(
                child: _EmptyState(selectedFilter: selectedFilter),
              )
                  : SliverList.separated(
                itemCount: filteredCourses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final course = filteredCourses[index];

                  return FadeTransition(
                    opacity: fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: fadeAnimation,
                        curve: Interval(
                          index * 0.1,
                          1.0,
                          curve: Curves.easeOutBack,
                        ),
                      )),
                      child: _EnhancedCourseCard(
                        course: course,
                        baseUrl: baseUrlState.baseUrl,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BlocProvider<CourseDetailsCubit>(
                                    create: (context) =>
                                    getIt<CourseDetailsCubit>()
                                      ..init(course),
                                    child: CourseDetailsScreen(course: course),
                                  ),
                            ),
                          );

                          cubit.init();
                          FirebaseAnalytics.instance.logEvent(
                            name: 'course_detail_event',
                            parameters: {
                              'param1': 'value1',
                              'param2': 123,
                            },
                          ).then((value) {
                            logger.e('Event successfully logged');
                          }).catchError((error) {
                            logger.e('Failed to log event: $error');
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),

        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  List<dynamic> _getFilteredCourses() {
    switch (selectedFilter) {
      case CourseFilterType.myCourses:
        return state.courseList.where((course) => course.isEnrolled).toList();
      case CourseFilterType.allCourses:
        return state.courseList;
    }
  }
}

class _CustomSegmentedControl extends StatelessWidget {
  final CourseFilterType selectedFilter;
  final Function(CourseFilterType) onFilterChanged;

  const _CustomSegmentedControl({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: ChessColors.greyG800.withOpacity(0.6),
        borderRadius: ChessRadius.radiusLg,
        border: Border.all(
          color: ChessColors.primaryDefault.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              title: "Mening kurslarim",
              isSelected: selectedFilter == CourseFilterType.myCourses,
              onTap: () => onFilterChanged(CourseFilterType.myCourses),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              title: "Barcha kurslar",
              isSelected: selectedFilter == CourseFilterType.allCourses,
              onTap: () => onFilterChanged(CourseFilterType.allCourses),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SegmentButton> createState() => _SegmentButtonState();
}

class _SegmentButtonState extends State<_SegmentButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? ChessColors.primaryDefault
                  : Colors.transparent,
              borderRadius: ChessRadius.radiusMd,
              boxShadow: widget.isSelected
                  ? [
                BoxShadow(
                  color: ChessColors.primaryDefault.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
            child: Center(
              child: Text(
                widget.title,
                style: context.textTheme.bodyMedium.copyWith(
                  color: widget.isSelected
                      ? ChessColors.white
                      : ChessColors.greyG300,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EnhancedCourseCard extends StatefulWidget {
  final dynamic course;
  final String baseUrl;
  final VoidCallback onTap;

  const _EnhancedCourseCard({
    required this.course,
    required this.baseUrl,
    required this.onTap,
  });

  @override
  State<_EnhancedCourseCard> createState() => _EnhancedCourseCardState();
}

class _EnhancedCourseCardState extends State<_EnhancedCourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _hoverController.forward(),
      onTapUp: (_) => _hoverController.reverse(),
      onTapCancel: () => _hoverController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ChessColors.greyG800.withOpacity(0.8),
                  ChessColors.greyG700.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: ChessRadius.radiusLg,
              border: Border.all(
                color: ChessColors.primaryDefault.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: ChessColors.greyG900.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: ChessColors.primaryDefault.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: ChessRadius.radiusMd,
                          border: Border.all(
                            color: ChessColors.primaryDefault.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ChessColors.greyG900.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: ChessRadius.radiusMd,
                          child: ChessNetworkImage(
                            imageUrl: widget.course.icon,
                            fit: BoxFit.cover,
                            height: 80,
                            width: 80,
                            baseUrl: widget.baseUrl,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Course Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.course.name,
                                    style: context.textTheme.title1Regular.copyWith(
                                      color: ChessColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.course.isEnrolled)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ChessColors.primaryDefault.withOpacity(0.2),
                                      borderRadius: ChessRadius.radiusSm,
                                      border: Border.all(
                                        color: ChessColors.primaryDefault.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      "Enrolled",
                                      style: TextStyle(
                                        color: ChessColors.primaryDefault,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.course.shortDescription,
                              style: context.textTheme.bodyMedium.copyWith(
                                color: ChessColors.greyG300,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Course Stats
                  Row(
                    children: [
                      _CourseStatItem(
                        icon: Icons.play_circle_outline,
                        label: "${widget.course.lessonsCount ?? 0} dars",
                        color: ChessColors.primaryDefault,
                      ),
                      const SizedBox(width: 16),
                      _CourseStatItem(
                        icon: Icons.access_time,
                        label: "${widget.course.duration ?? 0} min",
                        color: Colors.orange,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: ChessColors.primaryDefault,
                        size: 16,
                      ),
                    ],
                  ),

                  // Progress Bar (if enrolled)
                  // if (widget.course.isEnrolled && widget.course.progress != null)
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Progress",
                              style: context.textTheme.bodyMedium.copyWith(
                                color: ChessColors.greyG400,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              "${widget.course.progress}%",
                              style: context.textTheme.bodyMedium.copyWith(
                                color: ChessColors.primaryDefault,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: ChessRadius.radiusSm,
                          child: LinearProgressIndicator(
                            value: (widget.course.progress ?? 0) / 100,
                            backgroundColor: ChessColors.greyG700,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              ChessColors.primaryDefault,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CourseStatItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.textTheme.bodyMedium.copyWith(
            color: ChessColors.greyG300,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final CourseFilterType selectedFilter;

  const _EmptyState({required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    final isMyCourses = selectedFilter == CourseFilterType.myCourses;

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ChessColors.greyG800.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMyCourses ? Icons.school_outlined : Icons.search_off,
              color: ChessColors.greyG400,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isMyCourses ? "Hali kursga yozilmagansiz" : "Kurslar topilmadi",
            style: context.textTheme.title1Regular.copyWith(
              color: ChessColors.greyG300,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isMyCourses
                ? "Barcha kurslar bo'limidan kerakli kursni toping va ro'yxatdan o'ting"
                : "Hozircha bu bo'limda kurslar mavjud emas",
            style: context.textTheme.bodyMedium.copyWith(
              color: ChessColors.greyG400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}