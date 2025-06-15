import 'package:dio/dio.dart';
import 'package:founders_academy/core/api/api_client_manager.dart';

import 'package:injectable/injectable.dart';

const _authorizedApiClientInjectionName = 'AuthorizedApiClient';
const _unauthorizedApiClientInjectionName = 'UnauthorizedApiClient';

const authorizedApiClient = Named(_authorizedApiClientInjectionName);
const unauthorizedApiClient = Named(_unauthorizedApiClientInjectionName);

@module
abstract class ApiClientModule {
  @authorizedApiClient
  Dio getAuthorizedApiClient(ApiClientManager manager) =>
      manager.authorizedClient;

  @unauthorizedApiClient
  Dio getUnauthorizedApiClient(ApiClientManager manager) =>
      manager.unauthorizedClient;
}
