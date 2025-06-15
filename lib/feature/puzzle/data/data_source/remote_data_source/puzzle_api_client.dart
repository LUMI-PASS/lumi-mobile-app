import 'package:founders_academy/core/api/api_response.dart';
import 'package:founders_academy/di/module/api_client_module.dart';
import 'package:founders_academy/feature/puzzle/data/model/grandmaster_bot/grandmasters_bot_response.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle/puzzle_response.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle_module/puzzle_module_response.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle_report/puzzle_report_data.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle_submission/puzzle_submission_response.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'puzzle_api_client.g.dart';

@injectable
@RestApi()
abstract class PuzzleApiClient {
  @factoryMethod
  factory PuzzleApiClient(@authorizedApiClient Dio dio) = _PuzzleApiClient;

  @GET('/api/puzzle-module')
  Future<ApiResponse<PuzzleModuleListResponse>> getPuzzleModules();

  @GET('/api/uzchess-bot-module')
  Future<GrandMasterBotResponse> getGrandMasterBotList();

  @GET('/api/puzzles')
  Future<ApiResponse<PuzzleResponse>> getPuzzle(
    @Query("puzzle_type") String puzzleType,
  );

  @POST('/api/puzzles/{id}/report')
  Future<ApiResponse<PuzzleReportData>> puzzleReport({
    @Path('id') required String id,
    @Body() required PuzzleReportData puzzleReportData,
  });

  @POST('/api/puzzles/puzzlerush')
  Future<PuzzleQuickResponse> getPuzzleQuick(
    @Query('limit') int limit,
    @Body() Map<String, dynamic> body,
  );
  @POST('/api/puzzles/puzzlerush-submit')
  Future<ApiResponse<int>> submitSolvedPuzzles(
    @Body() Map<String, List<String>> body,
  );
  @POST('/api/puzzles/{id}/submit')
  Future<ApiResponse<PuzzleSubmissionResponse>> setMove(
    @Path("id") String id,
    @Field("is_hint_used") bool isHintUsed,
    @Field("is_retried") bool isRetried,
    @Field("tried_count") int triedCount,
    @Field("time") int time,
  );
}
