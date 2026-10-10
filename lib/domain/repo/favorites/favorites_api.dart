import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// The customer's saved activities and centres — "Saqlanganlar".
///
/// Every call needs a token: the server keeps one shelf per account and the
/// token says whose. Never call these signed out — a 401 here signs the user
/// out through `AuthInterceptor`, so the caller checks first.
@injectable
class FavoritesApi {
  final Dio _dio;

  FavoritesApi(this._dio);

  /// Just the saved ids, newest first — what the hearts tint from. `data` is
  /// the activities (courses included), `branches` the centres.
  Future<Response> ids() => _dio.get('favorites/ids');

  /// The shelf itself, as the cards `discovery/classes` returns.
  Future<Response> list({int page = 1, int limit = 50}) {
    return _dio.get(
      'favorites',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  /// Saves an activity. Idempotent — saving a saved one changes nothing.
  Future<Response> add(String activityId) => _dio.put('favorites/$activityId');

  /// Un-saves an activity. Succeeds whether or not it was saved.
  Future<Response> remove(String activityId) =>
      _dio.delete('favorites/$activityId');

  /// The saved centres, as the cards `discovery/branches` returns.
  Future<Response> listBranches({int page = 1, int limit = 50}) {
    return _dio.get(
      'favorites/branches',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  /// Saves a centre. Idempotent.
  Future<Response> addBranch(String branchId) =>
      _dio.put('favorites/branches/$branchId');

  /// Un-saves a centre. Succeeds whether or not it was saved.
  Future<Response> removeBranch(String branchId) =>
      _dio.delete('favorites/branches/$branchId');
}
