import 'package:founders_academy/feature/auth/data/data_source/token_data_source.dart';
import 'package:founders_academy/feature/auth/data/data_source/user_data_source.dart';
import 'package:injectable/injectable.dart';

@Singleton()
class UserSessionManager {
  @Injectable()
  final TokenDataSource _tokenDataSource;

  @Injectable()
  final UserDataDataSource _userDataDataSource;

  UserSessionManager(
    this._tokenDataSource,
    this._userDataDataSource,
  );

  Future<bool> isFirstRun() async {
    return _userDataDataSource.isFirstRun();
  }

  Future<bool> isUserLoggedIn() async {
    final token = await _tokenDataSource.getToken();
    return token != null;
  }

  Future<void> saveUserToken(String token) async {
    await _tokenDataSource.saveToken(token);
  }

  Future<String?> getToken() async {
    return _tokenDataSource.getToken();
  }

  Future<String?> getUserId() async {
    final userData = await _userDataDataSource.getUserId();
    return userData;
  }

  Future<void> saveUserId(String userId) async {
    await _userDataDataSource.saveUserId(userId);
  }

  Future<void> clearUserSession() async {
    await _tokenDataSource.clearToken();
    await _userDataDataSource.clearUserData();
  }
}
