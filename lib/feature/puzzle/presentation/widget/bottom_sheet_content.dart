import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle_report/puzzle_report_data.dart';
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle_report/puzzle_report_cubit.dart';
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle_report/puzzle_report_state.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomSheetContent extends StatefulWidget {
  final String puzzleId;

  const BottomSheetContent({
    required this.puzzleId,
    super.key,
  });

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  final _textController = TextEditingController();
  final _textFocusNode = FocusNode();

  bool _wrongAnswer = false;
  bool _technicIssue = false;
  bool _isButtonAvailable = false;

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PuzzleReportCubit>(),
      child: BlocConsumer<PuzzleReportCubit, PuzzleReportState>(
        listener: (context, state) {
          if (state is PuzzleReportLoadedState) {
            context.router.pop();
          }
        },
        builder: (context, state) {
          return Container(
            height: MediaQuery.sizeOf(context).height * 0.5,
            decoration: BoxDecoration(
              borderRadius: ChessRadius.radiusXl,
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24)
                  .copyWith(bottom: 36),
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 24, top: 8, left: 24, right: 24),
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 6,
                              width: 34,
                              decoration: BoxDecoration(
                                color: ChessColors.greyG30,
                                borderRadius: ChessRadius.radiusXl,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "Xatolik haqida xabar berish",
                          style: context.textTheme.bodyRegular.copyWith(
                            color: ChessColors.greyG900,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ChessTextField(
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                _isButtonAvailable = true;
                              });
                            } else {
                              setState(() {
                                _isButtonAvailable = false;
                              });
                            }
                          },
                          height: 150,
                          maxLines: 5,
                          focusNode: _textFocusNode,
                          controller: _textController,
                          placeholder: "Muammoni batafsil izohlang...",
                          autofocus: true,
                        ),
                        const SizedBox(height: 20),
                        _CheckBox(
                          issueDescription: "Noto'g'ri javob",
                          value: _wrongAnswer,
                          onChanged: (newValue) {
                            setState(() {
                              _wrongAnswer = newValue ?? false;
                            });
                          },
                        ),
                        const SizedBox(height: 28),
                        _CheckBox(
                          issueDescription: "Texnik xatolik",
                          value: _technicIssue,
                          onChanged: (newValue) {
                            setState(() {
                              _technicIssue = newValue ?? false;
                            });
                          },
                        ),
                        const Spacer(),
                        ChessButton.primary(
                          onPressed: _isButtonAvailable
                              ? () {
                                  final reason = PuzzleReportData(
                                    body: _textController.text,
                                    isWrongAnswer: _wrongAnswer,
                                    isTechnicalError: _technicIssue,
                                  );
                                  context
                                      .read<PuzzleReportCubit>()
                                      .puzzleReport(
                                        id: widget.puzzleId,
                                        puzzleReport: reason,
                                      );
                                }
                              : null,
                          label: 'Yuborish',
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  final String issueDescription;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckBox({
    required this.issueDescription,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: Checkbox(
                visualDensity: VisualDensity.compact,
                activeColor: ChessColors.primaryDefault,
                shape: RoundedRectangleBorder(
                  borderRadius: ChessRadius.radius3xs,
                ),
                side: MaterialStateBorderSide.resolveWith(
                  (states) => const BorderSide(
                    width: 1,
                    color: ChessColors.greyG50,
                  ),
                ),
                value: value,
                onChanged: onChanged),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              issueDescription,
              style: context.textTheme.bodyRegular.copyWith(
                color: ChessColors.greyG900,
              ),
            ),
          )
        ],
      ),
    );
  }
}
