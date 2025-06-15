import 'package:lumi_pass/core/api/api_response.dart';
import 'package:lumi_pass/di/module/api_client_module.dart';
import 'package:lumi_pass/feature/home/data/model/search_list/search_list_response.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'search_api_client.g.dart';

@injectable
@RestApi()
abstract class SearchApiClient {
  @factoryMethod
  factory SearchApiClient(@authorizedApiClient Dio dio) = _SearchApiClient;

  @GET('/api/search')
  Future<ApiResponse<SearchListResponse>> search(
    @Query('q') String query,
  );
}
