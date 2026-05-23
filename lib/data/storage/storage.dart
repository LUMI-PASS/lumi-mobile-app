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

  BaseStorage<String> get parentId => BaseStorage(_box, 'parent_id');

  BaseStorage<Tokens> get tokens => BaseStorage(_box, 'tokens');

  BaseStorage<int> get code => BaseStorage(_box, 'code');

  BaseStorage<String> get codeHash => BaseStorage(_box, 'codeHash');

  BaseStorage<String> get deviceToken => BaseStorage(_box, 'device_token');

  BaseStorage<String?> get currencyCode => BaseStorage(_box, 'currencyCode');

  BaseStorage<String?> get localeCode => BaseStorage(_box, 'localeCode');

  BaseStorage<bool> get needsOnboarding => BaseStorage(_box, 'needsOnboarding');

  BaseStorage<String> get pendingPhone => BaseStorage(_box, 'pendingPhone');

  BaseStorage<String> get parentName => BaseStorage(_box, 'parentName');

  BaseStorage<String> get childName => BaseStorage(_box, 'childName');

  BaseStorage<int> get childAge => BaseStorage(_box, 'childAge');

  BaseStorage<bool> get hasPremium => BaseStorage(_box, 'hasPremium');

  BaseStorage<int> get planDiscountPercentage => BaseStorage(_box, 'planDiscountPercentage');

  Future<void> logout() async {
    await tokens.set(null);
    await code.set(null);
    await codeHash.set(null);
    await deviceToken.set(null);
    await hasPremium.set(null);
    await planDiscountPercentage.set(null);
  }
// BaseStorage<String> get username => BaseStorage(_box, 'username');
//
// BaseStorage<String> get imagePath => BaseStorage(_box, 'imagePath');
//
// BaseStorage<int> get tsjId => BaseStorage(_box, 'tsjId');
//
// BaseStorage<String> get deviceToken => BaseStorage(_box, 'device_token');
}
