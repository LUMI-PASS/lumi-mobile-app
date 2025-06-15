import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/home/presentation/cubit/main_cubit/main_cubit.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

@override
void initState() {
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return getIt<MainCubit>()..init(context, context.router.pop);
      },
      child: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          return AutoTabsRouter(
            routes: const [
              HomeRoute(),
              CoursesRoute(),
              DiscussionsRoute(),
              ProfileContainerRoute(),
            ],
            transitionBuilder: (context, child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
            builder: (context, child) {
              final tabsRouter = AutoTabsRouter.of(context);

              return Scaffold(
                body: child,
                bottomNavigationBar: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    enableFeedback: true,
                    elevation: 0,
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    selectedItemColor: ChessColors.primaryDefault,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    unselectedItemColor: ChessColors.greyG40,
                    // Gray
                    currentIndex: tabsRouter.activeIndex,
                    onTap: (index) {
                      tabsRouter.setActiveIndex(index);
                    },
                    items: [
                      BottomNavigationBarItem(
                        activeIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ChessColors.primaryDefault.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            CupertinoIcons.house_fill,
                            size: 22,
                            color: ChessColors.primaryDefault,
                          ),
                        ),
                        icon: const Icon(
                          CupertinoIcons.house,
                          size: 22,
                        ),
                        label: 'Bosh Sahifa',
                        backgroundColor: ChessColors.greyG800,
                      ),
                      BottomNavigationBarItem(
                        activeIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ChessColors.primaryDefault.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            CupertinoIcons.book_fill,
                            size: 22,
                            color: ChessColors.primaryDefault,
                          ),
                        ),
                        icon: const Icon(
                          CupertinoIcons.book,
                          size: 22,
                        ),
                        label: 'Kurslar',
                        backgroundColor: ChessColors.greyG800,
                      ),
                      BottomNavigationBarItem(
                        activeIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ChessColors.primaryDefault.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            CupertinoIcons.chat_bubble_2_fill,
                            size: 22,
                            color: ChessColors.primaryDefault,
                          ),
                        ),
                        icon: const Icon(
                          CupertinoIcons.chat_bubble_2,
                          size: 22,
                        ),
                        label: 'Muhokama',
                        backgroundColor: ChessColors.greyG800,
                      ),
                      BottomNavigationBarItem(
                        activeIcon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ChessColors.primaryDefault.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            CupertinoIcons.person_fill,
                            size: 22,
                            color: ChessColors.primaryDefault,
                          ),
                        ),
                        icon: const Icon(
                          CupertinoIcons.person,
                          size: 22,
                        ),
                        label: 'Profil',
                        backgroundColor: ChessColors.greyG800,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
