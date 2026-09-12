import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';

/// The shop's kill switch.
///
/// The case that matters is the one that cannot be tested against a live
/// Firebase: a cold start with no network, where Remote Config never
/// initialises. A feature switch has to answer SAFELY there, and "safely" for
/// a storefront with real stock and a delivery team behind it means off.
void main() {
  test('the shop is off when Remote Config never initialised', () {
    // The singleton is untouched here — `init()` is never called, which is
    // exactly the no-network cold start.
    expect(RemoteConfigService.instance.isShopEnabled, isFalse);
  });

  test('the other feature-shaped values still answer their own fallbacks', () {
    // Guards against a change to the uninitialised path that silently makes
    // every flag false — support would vanish from the profile with it.
    final config = RemoteConfigService.instance;
    expect(config.hasSupportPhone, isTrue);
    expect(config.hasSupportTelegram, isTrue);
  });
}
