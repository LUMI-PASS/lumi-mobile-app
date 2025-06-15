import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

typedef ChessBoardController = ChessController;

typedef Player = PlayerColor;

typedef PieceColor = Color;

class ChessBoard extends StatelessWidget {
  final ChessBoardController controller;
  final List<String> correctMoves;
  final void Function(bool) onMove;
  final bool disableUserMoves;
  final bool showHint;

  const ChessBoard({
    super.key,
    required this.controller,
    required this.correctMoves,
    required this.onMove,
    this.disableUserMoves = false,
    this.showHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChessBoardWidget(
      controller: controller,
      enableUserMoves: !disableUserMoves,
      square: showHint ? BoardSquare(positions: correctMoves) : null,
      onMove: () => onMove.call(_isCorrectMove()),
    );
  }

  bool _isCorrectMove() {
    for (var move in correctMoves) {
      final pgn = controller.game.pgn();
      final isExistMove = pgn.endsWith(pgn.contains("*") ? "$move *" : move);
      if (isExistMove) return true;
    }

    return false;
  }
}
