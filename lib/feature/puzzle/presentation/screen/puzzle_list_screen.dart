import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle_module/puzzle_module_data.dart';
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle_module/puzzle_module_cubit.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class PuzzleListScreen extends StatelessWidget {
  const PuzzleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PuzzleModuleCubit>()..init(),
      child: Scaffold(
        backgroundColor: ChessColors.greyG20,
        body: BlocBuilder<PuzzleModuleCubit, PuzzleModuleState>(
          builder: (context, state) {
            if (state is PuzzleModuleLoadedState) {
              return _BodyContent(state.puzzleModules);
            }
            return const ChessCircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  final List<PuzzleModuleData> puzzleModules;

  const _BodyContent(this.puzzleModules);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          surfaceTintColor: ChessColors.white,
          backgroundColor: ChessColors.greyG20,
          expandedHeight: 100,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 24, bottom: 24),
            centerTitle: false,
            title: Text(
              "Boshqotirma",
              style: context.textTheme.title3Bold.copyWith(
                color: ChessColors.black,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < puzzleModules.length) {
                  return Column(
                    children: [
                      _PuzzleCard(
                        moduleData: puzzleModules[index],
                        onTap: () => context.router.push(
                          PuzzleDetailsRoute(
                              puzzleModule: puzzleModules[index]),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                } else if (index == puzzleModules.length) {
                  return Column(
                    children: [
                      _PuzzleQuickCard(
                        onTap: () {
                          context.router.push(
                            const PuzzleQuickTypeRoute(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _PuzzleQuickCard1(
                        onTap: () {
                          context.router.push(const PuzzleListBotRoute());
                        },
                      )
                    ],
                  );
                }
                return null;
              },
              childCount: puzzleModules.length + 1,
            ),
          ),
        )
      ],
    );
  }
}

class _PuzzleCard extends StatelessWidget {
  final PuzzleModuleData moduleData;
  final VoidCallback onTap;

  const _PuzzleCard({
    required this.onTap,
    required this.moduleData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ChessColors.white,
          borderRadius: ChessRadius.radiusMd,
          boxShadow: ChessShadows.shadowLg,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ChessNetworkImage(
                    imageUrl: moduleData.icon,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    baseUrl: state.baseUrl,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moduleData.name,
                    style: context.textTheme.title3Bold.copyWith(
                      color: ChessColors.greyG900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Bir qadamda boshqotirma javobni toping",
                    style: context.textTheme.footnoteRegular.copyWith(
                      color: ChessColors.greyG200,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _PuzzleQuickCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PuzzleQuickCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ChessColors.white,
          borderRadius: ChessRadius.radiusMd,
          boxShadow: ChessShadows.shadowLg,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChessUiKitAssets.icons.puzzle.puzzle1.image(height: 40, width: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tezkor boshqotirma",
                    style: context.textTheme.title3Bold.copyWith(
                      color: ChessColors.greyG900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Vaqtga qarshi kurash",
                    style: context.textTheme.footnoteRegular.copyWith(
                      color: ChessColors.greyG200,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _PuzzleQuickCard1 extends StatelessWidget {
  final VoidCallback onTap;

  const _PuzzleQuickCard1({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ChessColors.white,
          borderRadius: ChessRadius.radiusMd,
          boxShadow: ChessShadows.shadowLg,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChessUiKitAssets.icons.puzzle.robot.image(height: 48, width: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bot bilan o'ynash",
                    style: context.textTheme.title3Bold.copyWith(
                      color: ChessColors.greyG900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Sun’iy Intellekt botlarga qarshi kurashing",
                    style: context.textTheme.footnoteRegular.copyWith(
                      color: ChessColors.greyG200,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
