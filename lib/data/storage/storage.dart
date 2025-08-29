import 'package:lumi_pass/common/base/base_storage.dart';
import 'package:lumi_pass/data/base_model/token/tokens.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class Storage {
  Storage(this._box);

  final Box _box;

  @FactoryMethod(preResolve: true)
  static Future<Storage> create() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TokensImplAdapter());

    final box = await Hive.openBox('storage');
    return Storage(box);
  }

  BaseStorage<bool> get showOnboard => BaseStorage(_box, 'showOnboard');

  BaseStorage<String> get userId => BaseStorage(_box, 'user_id');

  BaseStorage<Tokens> get tokens => BaseStorage(_box, 'tokens');

  BaseStorage<int> get code => BaseStorage(_box, 'code');

  BaseStorage<String> get codeHash => BaseStorage(_box, 'codeHash');

  BaseStorage<String> get deviceToken => BaseStorage(_box, 'device_token');

  BaseStorage<String?> get currencyCode => BaseStorage(_box, 'currencyCode');

  Future<void> logout() async {
    await tokens.set(null);
    await code.set(null);
    await codeHash.set(null);
    await deviceToken.set(null);
  }
// BaseStorage<String> get username => BaseStorage(_box, 'username');
//
// BaseStorage<String> get imagePath => BaseStorage(_box, 'imagePath');
//
// BaseStorage<int> get tsjId => BaseStorage(_box, 'tsjId');
//
// BaseStorage<String> get deviceToken => BaseStorage(_box, 'device_token');
}
