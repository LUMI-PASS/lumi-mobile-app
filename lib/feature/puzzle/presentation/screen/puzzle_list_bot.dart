import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/grandmaster_bot/grandMaster_bot_state.dart';
import '../cubit/grandmaster_bot/grandmaster_bot_cubit.dart';

@RoutePage()
class PuzzleListBotScreen extends StatefulWidget {
  const PuzzleListBotScreen({super.key});

  @override
  State<PuzzleListBotScreen> createState() => _PuzzleListBotScreenState();
}

class _PuzzleListBotScreenState extends State<PuzzleListBotScreen> {
  int selectedBotIndex = 0; // Set initial index to 0
  int selectedLevelIndex = 0; // Add level selection index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessColors.greyG20,
      appBar: AppBar(
        backgroundColor: ChessColors.greyG20,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        title: Text(
          "Shaxmat AI",
          style: context.textTheme.title3Bold.copyWith(
            color: ChessColors.greyG900,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: GestureDetector(
            onTap: context.router.pop,
            child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
              height: 24,
              width: 24,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: BlocProvider(
          create: (context) => getIt<GrandMasterBotCubit>()..init(),
          child: BlocBuilder<GrandMasterBotCubit, GrandMasterBotState>(
            builder: (context, state) {
              if (state is GrandMasterBotLoadedState &&
                  state.grandMasterBotData.isNotEmpty) {
                final levelData = state.grandMasterBotData;

                if (levelData.isNotEmpty) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: ChessRadius.radiusSm,
                          color: ChessColors.white,
                          boxShadow: ChessShadows.shadowLg,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: ChessRadius.radiusMd,
                                  child: BlocBuilder<AppBaseUrlCubit,
                                      AppBaseUrlState>(
                                    builder: (context, state) {
                                      final bot = levelData[selectedLevelIndex]
                                          .bots?[selectedBotIndex];
                                      return ChessNetworkImage(
                                        imageUrl: bot?.image ?? "",
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        baseUrl: state.baseUrl,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  levelData[selectedLevelIndex]
                                          .bots?[selectedBotIndex]
                                          .fullName ??
                                      "No Name",
                                  style: context.textTheme.title3Bold.copyWith(
                                    color: ChessColors.greyG900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  levelData[selectedLevelIndex]
                                          .bots?[selectedBotIndex]
                                          .description ??
                                      "No Description",
                                  style: context.textTheme.footnoteRegular
                                      .copyWith(
                                    color: ChessColors.greyG200,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ChessUiKitAssets.icons.general.queenIcon
                                        .svg(
                                      fit: BoxFit.none,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      levelData[selectedLevelIndex]
                                              .bots?[selectedBotIndex]
                                              .rating
                                              ?.toString() ??
                                          "N/A",
                                      style: context
                                          .textTheme.subheadlineSemibold
                                          .copyWith(
                                        color: ChessColors.greyG900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Display the levels and bots
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 16),
                          itemCount: levelData.length,
                          itemBuilder: (context, levelIndex) {
                            final level = levelData[levelIndex];
                            final bots = level.bots ?? [];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    level.name ?? "No Level",
                                    style:
                                        context.textTheme.bodyMedium.copyWith(
                                      color: ChessColors.greyG900,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4, // Adjust columns
                                    mainAxisSpacing: 16.0,
                                    crossAxisSpacing: 4.0,
                                    mainAxisExtent: 88,
                                  ),
                                  itemBuilder: (context, botIndex) {
                                    final bot = bots[botIndex];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedBotIndex = botIndex;
                                          selectedLevelIndex = levelIndex;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: ChessRadius.radiusMd,
                                          border: Border.all(
                                            color:
                                                botIndex == selectedBotIndex &&
                                                        levelIndex ==
                                                            selectedLevelIndex
                                                    ? ChessColors.primaryDefault
                                                    : ChessColors.white,
                                            width: 4,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: ChessRadius.radiusSm,
                                          child: BlocBuilder<AppBaseUrlCubit,
                                              AppBaseUrlState>(
                                            builder: (context, state) {
                                              return ChessNetworkImage(
                                                imageUrl:
                                                    bot.image ?? "No Image",
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                baseUrl: state.baseUrl,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: bots.length,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Add this variable to get the selected bot link
                      ChessButton.primary(
                        onPressed: () {
                          final selectedBot = levelData[selectedLevelIndex]
                              .bots?[selectedBotIndex];
                          if (selectedBot?.botLink != null) {
                            context.router.push(
                              PuzzleWithBotRoute(
                                  url: selectedBot?.botLink ?? ""),
                            );
                          }
                        },
                        label: "O'ynash",
                      ),
                      const SizedBox(height: 50),
                    ],
                  );
                } else {
                  return Center(
                    child: Text(
                      "Tez Orada Botlar Qo'shiladi",
                      style: context.textTheme.footnoteRegular.copyWith(
                        color: ChessColors.greyG200,
                      ),
                    ),
                  );
                }
              } else if (state is GrandMasterBotErrorState) {
                return const Center(
                  child: SizedBox(),
                );
              }
              return const Center(
                child: ChessCircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
