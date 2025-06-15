import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@Injectable()
class UserDataDataSource {
  static const _firstRunKey = 'first_run';
  static const _userIdKey = 'user_id_key';

  final SharedPreferences _sharedPreferences;

  UserDataDataSource(this._sharedPreferences);

  Future<bool> isFirstRun() async {
    final isFirstRun = _sharedPreferences.getBool(_firstRunKey) ?? true;
    if (isFirstRun) {
      await _sharedPreferences.setBool(_firstRunKey, false);
    }
    return isFirstRun;
  }

  Future<void> saveUserId(String userId) async {
    await _sharedPreferences.setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    return _sharedPreferences.getString(_userIdKey);
  }

  Future<void> clearUserData() async {
    await _sharedPreferences.remove(_userIdKey);
  }
}
