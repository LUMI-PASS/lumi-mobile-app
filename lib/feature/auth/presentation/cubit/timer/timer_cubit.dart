import 'dart:async';

import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';

class TimerCubit extends ChessCubit<String> {
  late Timer _timer;
  static const int initialDuration = 60;

  TimerCubit() : super(_formatDuration(initialDuration)) {
    _startTimer();
  }
  String get empty => "";

  bool get isProcessing => state != "00:00";

  static String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (state.isNotEmpty && state != '00:00') {
          final remainingDuration = int.parse(state.split(':')[0]) * 60 +
              int.parse(state.split(':')[1]) -
              1;
          safeEmit(_formatDuration(remainingDuration));
        } else {
          _timer.cancel();
        }
      },
    );
  }

  void restartTimer() {
    _timer.cancel();
    safeEmit(_formatDuration(initialDuration));
    _startTimer();
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
