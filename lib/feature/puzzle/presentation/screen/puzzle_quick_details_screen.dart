import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle/puzzle_quick_data.dart';
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle_quick/puzzle_quick_cubit.dart';
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle_quick/puzzle_quick_state.dart';
import 'package:founders_academy/feature/puzzle/presentation/widget/action_tab.dart';
import 'package:founders_academy/feature/puzzle/presentation/widget/bottom_sheet_content.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class PuzzleQuickDetailsScreen extends StatefulWidget {
  final String selectedCount;
  final List<String> puzzleType;
  final int limit;

  const PuzzleQuickDetailsScreen({
    required this.selectedCount,
    required this.puzzleType,
    required this.limit,
    super.key,
  });

  @override
  State<PuzzleQuickDetailsScreen> createState() =>
      _PuzzleQuickDetailsScreenState();
}

class _PuzzleQuickDetailsScreenState extends State<PuzzleQuickDetailsScreen> {
  late ChessBoardController controller;
  final List<String> solvedPuzzleIds = [];

  int currentIndex = 0;
  int correctCount = 0;
  int score = 0;
  Widget moveResult = const SizedBox();
  bool isFirstMove = true;
  late int remainingTime;
  Timer? timer;
  String currentTurn = "";
  late PuzzleQuickCubit cubit;

  @override
  void initState() {
    super.initState();
    controller = ChessBoardController();
    remainingTime = widget.limit;
    cubit = getIt<PuzzleQuickCubit>()..init(widget.puzzleType, widget.limit);
    startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit.stream.listen((state) {
        if (state is PuzzleQuickLoadedState && state.puzzles.isNotEmpty) {
          loadPuzzle(state.puzzles[0]);
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void updateTurn() {
    final moves = controller.game
        .pgn()
        .split(' ')
        .where((move) => !move.contains('.'))
        .length;
    setState(() {
      currentTurn = (moves % 2 == 0)
          ? "Oqlar uchun eng afzal yo'lni toping"
          : "Qoralar uchun eng afzal yo'lni toping";
    });
  }

  void loadPuzzle(PuzzleQuickData puzzle) {
    controller.loadPGN(puzzle.boardState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        moveResult = const SizedBox();
        isFirstMove = true;
        updateTurn();
      });
    });
  }

  void nextPuzzle(List<PuzzleQuickData> puzzles) {
    if (currentIndex < puzzles.length - 1) {
      setState(() {
        currentIndex++;
        loadPuzzle(puzzles[currentIndex]);
      });
    } else {
      context.replaceRoute(PuzzleResultRoute(
          currentIndex: currentIndex,
          score: score,
          correctPuzzleCount: correctCount));
      submitSolvedPuzzles();
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (remainingTime == 0) {
        timer.cancel();
        submitSolvedPuzzles();
        context.replaceRoute(PuzzleResultRoute(
            currentIndex: currentIndex,
            score: score,
            correctPuzzleCount: correctCount));
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> submitSolvedPuzzles() async {
    await cubit.submitSolvedPuzzles(solvedPuzzleIds);
  }

  int getPuzzleScore(String type) {
    switch (type) {
      case 'easy':
        return 3;
      case 'medium':
        return 5;
      case 'hard':
        return 7;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit,
      child: Scaffold(
        body: BlocBuilder<PuzzleQuickCubit, PuzzleQuickState>(
          builder: (context, state) {
            if (state is PuzzleQuickInitState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is PuzzleQuickLoadedState) {
              final puzzles = state.puzzles;
              final puzzle = puzzles[currentIndex];
              return SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _PuzzleLabel(
                            name: puzzle.puzzleType == "easy"
                                ? "Oson"
                                : puzzle.puzzleType == "medium"
                                    ? "O'rtacha"
                                    : "Qiyin",
                            alignment: MainAxisAlignment.start,
                            isBold: false,
                          ),
                          _PuzzleLabel(
                            name: "${currentIndex + 1}",
                            alignment: MainAxisAlignment.center,
                            isBold: true,
                          ),
                          _PuzzleLabel(
                            name: _formatTime(remainingTime),
                            alignment: MainAxisAlignment.end,
                            isBold: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ChessBoard(
                                  controller: controller,
                                  correctMoves: puzzle.correctMoves,
                                  onMove: (bool isCorrect) {
                                    setState(() {
                                      moveResult =
                                          _ResultIcon(isCorrect: isCorrect);
                                      isFirstMove = false;
                                      if (isCorrect) {
                                        score +=
                                            getPuzzleScore(puzzle.puzzleType);
                                        correctCount++;
                                        solvedPuzzleIds.add(puzzle.id);
                                      }
                                      updateTurn(); // Update turn after move
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    puzzle.index != null
                                        ? "ID: ${puzzle.index}"
                                        : "",
                                    style:
                                        context.textTheme.bodyRegular.copyWith(
                                      color: ChessColors.greyG70,
                                    ),
                                  ),
                                ),
                                if (isFirstMove)
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ChessUiKitAssets.icons.general.queenIcon
                                            .svg(),
                                        const SizedBox(width: 5),
                                        Text(currentTurn,
                                            textAlign: TextAlign.center,
                                            style: context
                                                .textTheme.headlineSemibold
                                                .copyWith(
                                                    color:
                                                        ChessColors.greyG900)),
                                      ],
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: Center(child: moveResult),
                                  ),
                                Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                          color: ChessColors.greyG30),
                                    ),
                                    color: ChessColors.white,
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        ActionTab(
                                          title: "Chiqish",
                                          icon: ChessUiKitAssets
                                              .icons.puzzle.back.keyName,
                                          onTap: () {
                                            if (Platform.isIOS) {
                                              showCupertinoModalPopup(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        CupertinoAlertDialog(
                                                  title: const Text("Chiqish"),
                                                  content: const Text(
                                                      "Siz o'yini tark etmoqchimisiz?"),
                                                  actions: <CupertinoDialogAction>[
                                                    CupertinoDialogAction(
                                                      isDestructiveAction: true,
                                                      onPressed: () {
                                                        context.router
                                                            .pop(context);
                                                        context.router.replace(
                                                            const PuzzleQuickTypeRoute());
                                                      },
                                                      child: const Text(
                                                        'Ha',
                                                        style: TextStyle(
                                                            color: ChessColors
                                                                .errorDefault),
                                                      ),
                                                    ),
                                                    CupertinoDialogAction(
                                                      isDefaultAction: true,
                                                      onPressed: () {
                                                        context.router
                                                            .pop(context);
                                                      },
                                                      child: const Text(
                                                        "Yo'q",
                                                        style: TextStyle(
                                                            color: ChessColors
                                                                .primaryDefault),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        AlertDialog(
                                                  backgroundColor:
                                                      ChessColors.white,
                                                  title: const Text("Chiqish"),
                                                  content: Text(
                                                    "Siz o'yini tark etmoqqchimisiz?",
                                                    style: context.textTheme
                                                        .subheadlineRegular
                                                        .copyWith(
                                                      color:
                                                          ChessColors.greyG900,
                                                    ),
                                                  ),
                                                  actions: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              ChessButton.text(
                                                            onPressed: () {
                                                              context.router
                                                                  .pop(context);
                                                              context.router
                                                                  .replace(
                                                                      const PuzzleQuickTypeRoute());
                                                            },
                                                            label: 'Ha',
                                                            textStyle:
                                                                const TextStyle(
                                                              color: ChessColors
                                                                  .errorDefault,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child:
                                                              ChessButton.text(
                                                            onPressed: () {
                                                              context.router
                                                                  .pop(context);
                                                            },
                                                            label: "Yo'q",
                                                            textStyle:
                                                                const TextStyle(
                                                              color: ChessColors
                                                                  .primaryDefault,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        ActionTab(
                                          title: "Xatolik bor",
                                          icon: ChessUiKitAssets
                                              .icons.puzzle.flag.keyName,
                                          onTap: () {
                                            showModalBottomSheet(
                                              useRootNavigator: true,
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) => Padding(
                                                padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom),
                                                child: const BottomSheetContent(
                                                  puzzleId: "",
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        ActionTab(
                                          title: "Keyingisi",
                                          color: moveResult is _ResultIcon
                                              ? ChessColors.primaryDefault
                                              : null,
                                          icon: moveResult is _ResultIcon
                                              ? ChessUiKitAssets.icons.puzzle
                                                  .nextFilled.keyName
                                              : ChessUiKitAssets.icons.puzzle
                                                  .nextOutlined.keyName,
                                          onTap: () => nextPuzzle(puzzles),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is PuzzleQuickErrorState) {
              return const SizedBox.expand();
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

class _PuzzleLabel extends StatelessWidget {
  final String name;
  final MainAxisAlignment alignment;
  final bool isBold;

  const _PuzzleLabel({
    required this.name,
    required this.alignment,
    required this.isBold,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle =
        isBold ? context.textTheme.title3Bold : context.textTheme.title3Regular;

    return Row(
      mainAxisAlignment: alignment,
      children: [
        const SizedBox(width: 8),
        Text(
          name,
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ResultIcon extends StatelessWidget {
  final bool isCorrect;

  const _ResultIcon({
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isCorrect
            ? ChessUiKitAssets.icons.puzzle.correct.svg()
            : ChessUiKitAssets.icons.puzzle.wrong.svg(),
        const SizedBox(width: 14),
        Text(
          isCorrect ? "Boshqotirma bajarildi" : "Boshqotirma bajarilmadi",
          style: context.textTheme.headlineSemibold,
        ),
      ],
    );
  }
}
