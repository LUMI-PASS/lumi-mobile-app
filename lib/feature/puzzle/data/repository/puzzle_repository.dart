import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/feature/puzzle/data/data_source/remote_data_source/puzzle_api_client.dart';
import 'package:founders_academy/feature/puzzle/data/model/grandmaster_bot/grandmasters_bot_response.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle/puzzle_data.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle/puzzle_response.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle_module/puzzle_module_data.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle_report/puzzle_report_data.dart';
import 'package:founders_academy/feature/puzzle/domain/repository/base_puzzle_repository.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: BasePuzzleRepository)
class PuzzleRepository implements BasePuzzleRepository {
  final PuzzleApiClient _puzzleApiClient;

  PuzzleRepository(this._puzzleApiClient);

  @override
  Future<List<PuzzleModuleData>?> getPuzzleModules() async {
    try {
      final response = await _puzzleApiClient.getPuzzleModules();

      return response.result.puzzleModules;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<PuzzleData?> getPuzzle({required String level}) async {
    try {
      final response = await _puzzleApiClient.getPuzzle(level);

      return response.result.puzzle;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<int?> setMove(
    String id, {
    required bool isHintUsed,
    required bool isRetried,
    required int triedCount,
    required int time,
  }) async {
    try {
      final submission = await _puzzleApiClient.setMove(
        id,
        isHintUsed,
        isRetried,
        triedCount,
        time,
      );

      return submission.result.earnedMark;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<PuzzleReportData> puzzleReport({
    required String id,
    required PuzzleReportData reportPuzzle,
  }) async {
    try {
      final response = await _puzzleApiClient.puzzleReport(
        id: id,
        puzzleReportData: reportPuzzle,
      );
      return response.result;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<PuzzleQuickResponse?> getPuzzleQuick(
      List<String> types, int limit) async {
    try {
      final response = await _puzzleApiClient.getPuzzleQuick(
        limit,
        {'type': types},
      );
      return response;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<int> submitSolvedPuzzles(List<String> solvedPuzzleIds) async {
    try {
      final response = await _puzzleApiClient.submitSolvedPuzzles({
        'puzzle_ids': solvedPuzzleIds,
      });
      return response.result;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<GrandMasterBotResponse> getGrandMasterBotList() async {
    try {
      final response = await _puzzleApiClient.getGrandMasterBotList();
      return response;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }
}
