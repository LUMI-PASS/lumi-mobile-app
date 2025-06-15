import 'package:founders_academy/feature/puzzle/data/model/grandmaster_bot/grandmasters_bot_response.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle/puzzle_data.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle/puzzle_response.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle_module/puzzle_module_data.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle_report/puzzle_report_data.dart';

abstract interface class BasePuzzleRepository {
  Future<List<PuzzleModuleData>?> getPuzzleModules();

  Future<PuzzleData?> getPuzzle({required String level});

  Future<GrandMasterBotResponse> getGrandMasterBotList();

  Future<PuzzleReportData> puzzleReport({
    required String id,
    required PuzzleReportData reportPuzzle,
  });
  Future<PuzzleQuickResponse?> getPuzzleQuick(List<String> types, int limit);
  Future<int?> setMove(
    String id, {
    required bool isHintUsed,
    required bool isRetried,
    required int triedCount,
    required int time,
  });

  Future<int> submitSolvedPuzzles(List<String> solvedPuzzleIds);
}
