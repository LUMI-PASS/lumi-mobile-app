import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle_module/puzzle_module_data.dart';
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle/puzzle_cubit.dart';
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle/puzzle_state.dart';
import 'package:founders_academy/feature/puzzle/presentation/widget/action_tab.dart';
import 'package:founders_academy/feature/puzzle/presentation/widget/bottom_sheet_content.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

@RoutePage()
class PuzzleDetailsScreen extends StatefulWidget {
  final PuzzleModuleData puzzleModule;

  const PuzzleDetailsScreen({
    super.key,
    required this.puzzleModule,
  });

  @override
  State<PuzzleDetailsScreen> createState() => _PuzzleDetailsScreenState();
}

class _PuzzleDetailsScreenState extends State<PuzzleDetailsScreen> {
  late PuzzleCubit cubit;

  @override
  void initState() {
    cubit = getIt<PuzzleCubit>()..init(widget.puzzleModule.level);
    super.initState();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit,
      child: Scaffold(
        body: BlocBuilder<PuzzleCubit, PuzzleState>(
          builder: (context, state) {
            return switch (state) {
              PuzzleLoadingState() => const ChessCircularProgressIndicator(),
              PuzzleLoadedState() => _BodyContent(widget.puzzleModule, state),
              PuzzleEmptyState() => const _EmptyContent(),
              _ => const SizedBox.expand(),
            };
          },
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return ChessResultScreen(
      image: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: ChessColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ChessUiKitAssets.icons.general.sadCircle.svg(
          height: 40,
          width: 40,
          fit: BoxFit.none,
        ),
      ),
      title: "Bu bo'lim hozirda bo'sh",
      subtitle:
          "Bu yerda sizga foydali bo'lgan ma'lumotlar tez orada taqdim etiladi",
      primaryButtonLabel: 'Ortga qaytish',
      onPrimaryButtonTap: context.router.pop,
    );
  }
}

class _BodyContent extends StatefulWidget {
  final PuzzleModuleData puzzleModule;
  final PuzzleLoadedState state;

  const _BodyContent(this.puzzleModule, this.state);

  @override
  State<_BodyContent> createState() => _BodyContentState();
}

class _BodyContentState extends State<_BodyContent> {
  late ChessBoardController controller;

  @override
  void initState() {
    controller = ChessBoardController();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _loadBoard();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _loadBoard() {
    controller.loadPGN(widget.state.puzzle.boardState ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
                  builder: (context, state) {
                    return Expanded(
                      child: _PuzzleLabel(
                        alignment: MainAxisAlignment.start,
                        name: widget.puzzleModule.name,
                        image: ChessNetworkImage(
                          imageUrl: widget.puzzleModule.icon,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          baseUrl: state.baseUrl,
                        ),
                      ),
                    );
                  },
                ),
                _PuzzleLabel(
                  alignment: MainAxisAlignment.center,
                  spinner: widget.state.submittingMove,
                  name: widget.state.puzzle.userPoints.toString(),
                  image: ChessUiKitAssets.icons.general.queenIcon.svg(),
                  isBoldText: true,
                ),
                Expanded(
                  child: _PuzzleLabel(
                    alignment: MainAxisAlignment.end,
                    name: widget.state.elapsedTime.formatTimer,
                    image: ChessUiKitAssets.icons.puzzle.timer.svg(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ChessBoard(
                        onMove: context.read<PuzzleCubit>().setMove,
                        disableUserMoves: widget.state.isCorrect != null,
                        controller: controller,
                        showHint: widget.state.isHintShowed,
                        correctMoves: widget.state.puzzle.correctMoves ?? [],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Text(
                          widget.state.puzzle.index != null
                              ? "ID: ${widget.state.puzzle.index}"
                              : "",
                          style: context.textTheme.bodyRegular.copyWith(
                            color: ChessColors.greyG70,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _StatusText(
                          type: widget.state.statusTextType,
                          puzzleTitle: widget.state.puzzle.title,
                          turn: controller.game.turn.name,
                        ),
                      ),
                      _ActonBar(
                        widget.state,
                        controller,
                        widget.puzzleModule.level,
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
  }
}

class _PuzzleLabel extends StatelessWidget {
  final Widget image;
  final String name;
  final bool isBoldText;
  final bool spinner;
  final MainAxisAlignment alignment;

  const _PuzzleLabel({
    required this.image,
    required this.name,
    this.isBoldText = false,
    required this.alignment,
    this.spinner = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = isBoldText
        ? context.textTheme.title3Bold
        : context.textTheme.title3Regular;

    return Row(
      mainAxisAlignment: alignment,
      children: [
        SizedBox(width: 24, height: 24, child: image),
        const SizedBox(width: 8),
        spinner
            ? _indicator
            : Text(
                name,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
      ],
    );
  }

  Widget get _indicator => const SizedBox.square(
        dimension: 16,
        child: ChessCircularProgressIndicator(strokeWidth: 2),
      );
}

class _StatusText extends StatelessWidget {
  final StatusTextType type;
  final String? puzzleTitle;
  final String turn;

  const _StatusText({
    required this.type,
    required this.puzzleTitle,
    required this.turn,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String? subtitle;
    String icon;
    TextStyle titleStyle = context.textTheme.headlineSemibold;
    TextStyle subtitleStyle = context.textTheme.subheadlineRegular;
    late String turn;

    switch (this.turn) {
      case "WHITE":
        turn = "Oqlar";
        break;
      case "BLACK":
        turn = "Qoralar";
        break;
    }

    switch (type) {
      case StatusTextType.explanation:
        icon = ChessUiKitAssets.icons.general.queenIcon.keyName;
        title = "$turn uchun eng yaxshi yurishni toping!";
        subtitle = puzzleTitle;
        titleStyle = context.textTheme.headlineSemibold;
        subtitleStyle = context.textTheme.subheadlineRegular;
        break;
      case StatusTextType.correct:
        icon = ChessUiKitAssets.icons.puzzle.correct.keyName;
        title = "Boshqotirma bajarildi";
        break;
      case StatusTextType.wrong:
        icon = ChessUiKitAssets.icons.puzzle.wrong.keyName;
        title = "Boshqotirma bajarilmadi";
        subtitle = "Boshqa yo'lni sinab ko'ring";
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          icon,
          width: 32,
          height: 32,
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: titleStyle),
            if (subtitle != null && subtitle.isNotEmpty)
              Text(subtitle, style: subtitleStyle),
          ],
        )
      ],
    );
  }
}

class _ActonBar extends StatelessWidget {
  final PuzzleLoadedState state;
  final ChessBoardController controller;
  final String puzzleLevel;

  const _ActonBar(
    this.state,
    this.controller,
    this.puzzleLevel,
  );

  @override
  Widget build(BuildContext context) {
    final helpRetryIcon = state.isWrongAnswer
        ? ChessUiKitAssets.icons.puzzle.restartFilled.keyName
        : ChessUiKitAssets.icons.puzzle.help.keyName;

    final nextIcon = state.isCorrectAnswer
        ? ChessUiKitAssets.icons.puzzle.nextFilled.keyName
        : ChessUiKitAssets.icons.puzzle.nextOutlined.keyName;

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ChessColors.greyG30)),
        color: ChessColors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ActionTab(
            title: "Chiqish",
            icon: ChessUiKitAssets.icons.puzzle.back.keyName,
            onTap: context.router.pop,
          ),
          ActionTab(
            title: "Xatolik bor",
            icon: ChessUiKitAssets.icons.puzzle.flag.keyName,
            onTap: () {
              showModalBottomSheet(
                useRootNavigator: true,
                context: context,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: BottomSheetContent(
                    puzzleId: state.puzzle.id ?? "",
                  ),
                ),
              );
            },
          ),
          ActionTab(
            title: state.isWrongAnswer ? "Qayta urinish" : "Yordam",
            color: state.isWrongAnswer ? ChessColors.errorDefault : null,
            icon: helpRetryIcon,
            onTap: !state.isCorrectAnswer
                ? () => _onHintRetryButtonTap(context)
                : null,
          ),
          ActionTab(
            title: "Keyingisi",
            color: state.isCorrectAnswer ? ChessColors.primaryDefault : null,
            icon: nextIcon,
            onTap: () => _onNextButtonTap(context),
          ),
        ],
      ),
    );
  }

  void _onHintRetryButtonTap(BuildContext context) {
    state.isWrongAnswer
        ? _resetBoard(context)
        : context.read<PuzzleCubit>().showHint();
  }

  void _resetBoard(BuildContext context) {
    _loadBoard();
    context.read<PuzzleCubit>().resetBoard();
  }

  void _loadBoard() {
    controller.loadPGN(state.puzzle.boardState ?? "");
  }

  void _onNextButtonTap(BuildContext context) {
    context.read<PuzzleCubit>().fetchPuzzle(puzzleLevel);
  }
}
