import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/di/get_it.dart';
import 'package:lumi_pass/feature/courses/data/model/course/course_data.dart';
import 'package:lumi_pass/feature/courses/presentation/cubit/course_details/course_details_cubit.dart';
import 'package:lumi_pass/feature/courses/presentation/screen/course_details_screen.dart';
import 'package:lumi_pass/feature/home/data/model/live_stream/live_stream_data.dart';
import 'package:lumi_pass/feature/home/presentation/cubit/home_cubit/home_cubit.dart';
import 'package:lumi_pass/feature/home/presentation/cubit/home_cubit/home_state.dart';
import 'package:lumi_pass/feature/home/presentation/screen/search_screen/search_screen.dart';
import 'package:lumi_pass/feature/home/presentation/widget/banner/live_banner.dart';
import 'package:lumi_pass/feature/home/presentation/widget/banner/live_banner_updated.dart';
import 'package:lumi_pass/feature/home/presentation/widget/banner/process_banner.dart';
import 'package:lumi_pass/feature/home/presentation/widget/group/book_group.dart';
import 'package:lumi_pass/feature/home/presentation/widget/group/companies_group.dart';
import 'package:lumi_pass/feature/home/presentation/widget/group/course_group.dart';
import 'package:lumi_pass/feature/home/presentation/widget/group/dicsussions_group.dart';
import 'package:lumi_pass/feature/home/presentation/widget/group/news_group.dart';
import 'package:lumi_pass/feature/home/presentation/widget/group/popular_startups_group.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/push_notification_cubit/push_notification_cubit.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutoRouteAwareStateMixin<HomeScreen> {
  late HomeCubit _cubit;
  late AnimationController _refreshController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    context.read<PushNotificationCubit>().subscribe();
    _cubit = getIt<HomeCubit>()..init();

    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Setup animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Start initial animations
    _fadeController.forward();
    _slideController.forward();

    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _refreshController.forward(from: 0.0);
    await _cubit.getActiveCourses();
    await _cubit.getActiveLiveStream();
    await _refreshController.reverse();

    // Trigger content refresh animation
    _fadeController.reset();
    await _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ChessColors.greyG900,
            body: RefreshIndicator(
              color: ChessColors.primaryDefault,
              backgroundColor: ChessColors.greyG800,
              onRefresh: _refreshData,
              child: SafeArea(
                child: Stack(
                  children: [
                    _BackgroundDecoration(
                        floatingAnimation: _floatingAnimation),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _EnhancedSliverAppBar(
                            slideController: _slideController,
                            fadeAnimation: _fadeAnimation,
                          ),
                          SliverToBoxAdapter(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: EventsSection(),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: const CourseGroup(),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: const CompaniesGroup(),
                            ),
                          ),

                          // Discussions Section
                          SliverToBoxAdapter(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: const DiscussionsGroup(),
                            ),
                          ),

                          // Popular Startup Members Section
                          SliverToBoxAdapter(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: const PopularStartupsGroup(),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: state.isLoading
                                  ? const _ShimmerContent()
                                  : _EnhancedBodyContent(
                                      state: state,
                                      fadeAnimation: _fadeAnimation,
                                    ),
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100),
                          ),
                        ],
                      ),
                    ),
                    _FloatingElements(floatingAnimation: _floatingAnimation),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  final Animation<double> floatingAnimation;

  const _BackgroundDecoration({required this.floatingAnimation});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: floatingAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Floating chess pieces as background decoration
              Positioned(
                top: 100 + floatingAnimation.value,
                right: 20,
                child: const Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.gamepad,
                    size: 60,
                    color: ChessColors.primaryDefault,
                  ),
                ),
              ),
              Positioned(
                top: 300 - floatingAnimation.value,
                left: 30,
                child: const Opacity(
                  opacity: 0.08,
                  child: Icon(
                    Icons.gamepad,
                    size: 40,
                    color: ChessColors.primaryDefault,
                  ),
                ),
              ),
              Positioned(
                bottom: 200 + floatingAnimation.value * 0.5,
                right: 40,
                child: const Opacity(
                  opacity: 0.12,
                  child: Icon(
                    Icons.gamepad,
                    size: 35,
                    color: ChessColors.primaryDefault,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EnhancedSliverAppBar extends StatelessWidget {
  final AnimationController slideController;
  final Animation<double> fadeAnimation;

  const _EnhancedSliverAppBar({
    required this.slideController,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: ChessColors.greyG800,
      backgroundColor: ChessColors.greyG900,
      expandedHeight: 140,
      collapsedHeight: 100,
      pinned: true,
      elevation: 0,
      actions: _buildAnimatedActions(context),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsetsDirectional.only(
          start: 0,
          bottom: 12,
        ),
        title: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.5, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: slideController,
            curve: Curves.easeOutBack,
          )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ChessColors.greyG800.withOpacity(0.8),
                  borderRadius: ChessRadius.radiusSm,
                  border: Border.all(
                    color: ChessColors.primaryDefault.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  "Bosh sahifa",
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
              const SizedBox(height: 4),
              FadeTransition(
                opacity: fadeAnimation,
                child: Text(
                  "Bugun nima o'rganamiz?",
                  style: context.textTheme.bodyMedium.copyWith(
                    color: ChessColors.greyG300,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedActions(BuildContext context) => [
        _AnimatedIconButton(
          icon: ChessUiKitAssets.icons.general.searchLg
              .svg(color: ChessColors.white),
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            useSafeArea: true,
            enableDrag: false,
            backgroundColor: ChessColors.greyG600,
            barrierColor: ChessColors.greyG900.withOpacity(0.8),
            builder: (context) => const SearchScreen(),
          ),
          delay: 200,
          slideController: slideController,
        ),
        const SizedBox(width: 8),
        _AnimatedIconButton(
          icon: Stack(
            children: [
              ChessUiKitAssets.icons.general.bell02
                  .svg(color: ChessColors.white),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: ChessColors.primaryDefault,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            context.router.push(const NotificationRoute());
          },
          delay: 400,
          slideController: slideController,
        ),
        const SizedBox(width: 16),
      ];
}

class _FloatingElements extends StatelessWidget {
  final Animation<double> floatingAnimation;

  const _FloatingElements({required this.floatingAnimation});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 20,
      child: AnimatedBuilder(
        animation: floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -floatingAnimation.value),
            child: FloatingActionButton(
              mini: true,
              backgroundColor: ChessColors.primaryDefault,
              onPressed: () {
                // Quick play action
              },
              child: const Icon(
                Icons.flash_on,
                color: ChessColors.white,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final int delay;
  final AnimationController slideController;

  const _AnimatedIconButton({
    required this.icon,
    required this.onPressed,
    required this.delay,
    required this.slideController,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: slideController,
        curve: Interval(
          delay / 1000,
          (delay + 300) / 1000,
          curve: Curves.elasticOut,
        ),
      )),
      child: Container(
        decoration: BoxDecoration(
          color: ChessColors.greyG800.withOpacity(0.9),
          borderRadius: ChessRadius.radiusMd,
          border: Border.all(
            color: ChessColors.primaryDefault.withOpacity(0.2),
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
        child: IconButton(
          icon: icon,
          onPressed: onPressed,
          splashRadius: 24,
          splashColor: ChessColors.primaryDefault.withOpacity(0.2),
          highlightColor: ChessColors.primaryDefault.withOpacity(0.1),
        ),
      ),
    );
  }
}

class _LiveStreamCard extends StatelessWidget {
  final LiveStreamData? liveStream;

  const _LiveStreamCard(this.liveStream);

  @override
  Widget build(BuildContext context) {
    LiveStreamData? currentLiveStream = liveStream;

    if (currentLiveStream == null) return const SizedBox.shrink();

    return _EnhancedBannerCard(
      gradient: LinearGradient(
        colors: [
          ChessColors.primaryDefault.withOpacity(0.8),
          ChessColors.primaryDefault.withOpacity(0.4),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: LiveBanner(liveStream: currentLiveStream),
      onTap: () {
        ChessUrlLauncher.launch(
          url: currentLiveStream.videoLink,
          onError: (_) {
            CornerCaseBottomSheet.show(
              context,
              type: CornerCaseType.error,
            );
          },
        );
      },
    );
  }
}

class _ActiveCourseCard extends StatelessWidget {
  final CourseData? activeCourse;

  const _ActiveCourseCard(this.activeCourse);

  @override
  Widget build(BuildContext context) {
    CourseData? currentCourse = activeCourse;

    if (currentCourse == null) return const SizedBox.shrink();

    return _EnhancedBannerCard(
      gradient: LinearGradient(
        colors: [
          ChessColors.greyG700,
          ChessColors.greyG800,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: ProcessBanner(course: currentCourse),
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider<CourseDetailsCubit>(
              create: (context) =>
                  getIt<CourseDetailsCubit>()..init(currentCourse),
              child: CourseDetailsScreen(course: currentCourse),
            ),
          ),
        ).then(
          (_) => context.read<HomeCubit>().getActiveCourses(),
        );
      },
    );
  }
}

class _EnhancedBodyContent extends StatelessWidget {
  final HomeState state;
  final Animation<double> fadeAnimation;

  const _EnhancedBodyContent({
    required this.state,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> contentWidgets = [];
    int animationDelay = 0;

    // Only keep books and news sections as requested
    if (state.bookList.isNotEmpty) {
      contentWidgets.add(_AnimatedContentSection(
        delay: animationDelay,
        fadeAnimation: fadeAnimation,
        child: BookGroup(bookList: state.bookList),
      ));
      animationDelay += 100;
    }

    if (state.newsList.isNotEmpty) {
      contentWidgets.add(_AnimatedContentSection(
        delay: animationDelay,
        fadeAnimation: fadeAnimation,
        child: NewsGroup(newsList: state.newsList),
      ));
    }

    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      itemCount: contentWidgets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => contentWidgets[index],
    );
  }
}

class _AnimatedContentSection extends StatelessWidget {
  final int delay;
  final Animation<double> fadeAnimation;
  final Widget child;

  const _AnimatedContentSection({
    required this.delay,
    required this.fadeAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: this.child,
          ),
        );
      },
      child: child,
    );
  }
}

class _EnhancedBannerCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Gradient gradient;

  const _EnhancedBannerCard({
    required this.child,
    required this.onTap,
    required this.gradient,
  });

  @override
  State<_EnhancedBannerCard> createState() => _EnhancedBannerCardState();
}

class _EnhancedBannerCardState extends State<_EnhancedBannerCard>
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
              gradient: widget.gradient,
              borderRadius: ChessRadius.radiusLg,
              border: Border.all(
                color: ChessColors.primaryDefault.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                const BoxShadow(
                  color: ChessColors.greyG800,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
                BoxShadow(
                  color: ChessColors.primaryDefault.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _ShimmerContent extends StatefulWidget {
  const _ShimmerContent();

  @override
  State<_ShimmerContent> createState() => _ShimmerContentState();
}

class _ShimmerContentState extends State<_ShimmerContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        _ShimmerBox(animation: _shimmerAnimation, height: 120),
        const SizedBox(height: 24),
        _ShimmerBox(animation: _shimmerAnimation, height: 100),
        const SizedBox(height: 24),
        _ShimmerBox(animation: _shimmerAnimation, height: 80),
        const SizedBox(height: 24),
        _ShimmerBox(animation: _shimmerAnimation, height: 140),
        const SizedBox(height: 24),
        _ShimmerBox(animation: _shimmerAnimation, height: 90),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final Animation<double> animation;
  final double height;

  const _ShimmerBox({
    required this.animation,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: ChessRadius.radiusMd,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                ChessColors.greyG800,
                ChessColors.greyG700,
                ChessColors.greyG800,
              ],
              stops: [
                0.0,
                animation.value.clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
