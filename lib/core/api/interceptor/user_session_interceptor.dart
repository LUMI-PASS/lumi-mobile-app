import 'package:founders_academy/feature/auth/domain/user_session_manager.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class UserSessionInterceptor extends Interceptor {
  @Injectable()
  final UserSessionManager _userSessionManager;

  UserSessionInterceptor(this._userSessionManager);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _userSessionManager.getToken();
    options.headers['Authorization'] = 'Bearer $token';

    handler.next(options);
  }
}
