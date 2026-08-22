import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// The one interest signal the backend cannot observe for itself.
///
/// Everything else a user does in the catalog already arrives at the server as
/// a request and is recorded there — see `InterestSourceInterceptor`. What
/// never arrives is a booking sheet OPENED and walked away from: no checkout
/// call is made, so as far as the backend is concerned it never happened.
///
/// The endpoint rejects any other kind, so this cannot grow into a second,
/// client-trusted copy of the view counts.
@injectable
class InterestsApi {
  final Dio _dio;

  InterestsApi(this._dio);

  /// Posts a batch of queued events. Auth required — the token says whose
  /// history these belong to; the body cannot name a user.
  Future<Response> report(List<Map<String, dynamic>> events) {
    return _dio.post('interests/events', data: {'events': events});
  }
}
