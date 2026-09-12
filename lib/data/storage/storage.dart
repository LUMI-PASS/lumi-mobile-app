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

  /// A random id generated once per install and never sent anywhere but our
  /// own API. NOT an identity — it exists so two taps a second apart can be
  /// recognised as one, and so an unauthenticated write has something to
  /// bound. Cleared with the app's data, like everything else in this box.
  BaseStorage<String?> get installId => BaseStorage(_box, 'install_id');

  BaseStorage<String?> get currencyCode => BaseStorage(_box, 'currencyCode');

  BaseStorage<String?> get localeCode => BaseStorage(_box, 'localeCode');

  /// User theme override for the redesigned screens: 'system' | 'light' | 'dark'.
  BaseStorage<String?> get themeMode => BaseStorage(_box, 'themeMode');

  BaseStorage<bool> get needsOnboarding => BaseStorage(_box, 'needsOnboarding');

  BaseStorage<String> get pendingPhone => BaseStorage(_box, 'pendingPhone');

  /// The logged-in user's phone number, persisted for the whole session
  /// (unlike [pendingPhone], which is transient onboarding state). Used to
  /// stamp every analytics event with the user's phone.
  BaseStorage<String> get userPhone => BaseStorage(_box, 'user_phone');

  /// Booking-intent events not yet accepted by the backend.
  ///
  /// Persisted rather than held in memory because the whole point of the
  /// signal is a user who lost interest and left — quite possibly closing the
  /// app, quite possibly on no connection. See [InterestReporter].
  BaseStorage<List> get pendingInterestEvents =>
      BaseStorage(_box, 'pending_interest_events');

  /// The shop basket, as a list of `{product_id, count}` maps.
  ///
  /// Local and not server-side: a basket is a scratchpad, and the server has
  /// no idea one exists — `POST /api/shop/checkout` takes the whole thing in
  /// one call. Persisting it here means closing the app does not empty it,
  /// which is the behaviour every store has trained people to expect.
  BaseStorage<List> get shopCart => BaseStorage(_box, 'shop_cart');

  BaseStorage<String> get parentName => BaseStorage(_box, 'parentName');

  /// Path of the parent's avatar on this device. The backend has no endpoint
  /// for a parent photo yet, so the picked file is kept locally and shown
  /// from here; swap this for the server URL once the upload exists.
  BaseStorage<String?> get avatarPath => BaseStorage(_box, 'avatarPath');

  BaseStorage<String> get childName => BaseStorage(_box, 'childName');

  BaseStorage<int> get childAge => BaseStorage(_box, 'childAge');

  BaseStorage<bool> get hasPremium => BaseStorage(_box, 'hasPremium');

  BaseStorage<int> get planDiscountPercentage => BaseStorage(_box, 'planDiscountPercentage');

  /// Whether the one-time "get coupon" reward promo has been shown on home.
  BaseStorage<bool> get couponPromoShown =>
      BaseStorage(_box, 'couponPromoShown');

  /// Whether we have already shown the OS location prompt once.
  ///
  /// The home feed asks for location on the user's first visit and never again:
  /// re-prompting each launch is what pushes people into denying permanently.
  /// A refusal just means the feed is ordered from the centre of Tashkent; if
  /// they later grant it in Settings, the permission check picks that up
  /// without this flag being involved.
  BaseStorage<bool> get locationAsked => BaseStorage(_box, 'locationAsked');

  /// Whether the user dismissed the "add your name and child" prompt that sits
  /// above the bottom nav. Persisted, so once it is closed it stays closed
  /// across launches — the profile details are a nice-to-have, not a gate.
  BaseStorage<bool> get profilePromptDismissed =>
      BaseStorage(_box, 'profilePromptDismissed');

  /// The `latest_app_version` the user last tapped "Later" on in the optional
  /// update sheet. The sheet stays quiet until the console names a newer one.
  /// Device-level, not account-level, so it survives a sign-out.
  BaseStorage<String?> get updateSkippedVersion =>
      BaseStorage(_box, 'updateSkippedVersion');

  /// The buyer's last-used payment rail ('payme'|'click'|'uzum'|'card'), so the
  /// booking sheet can pre-select it on the next checkout.
  BaseStorage<String?> get lastPaymentRail =>
      BaseStorage(_box, 'lastPaymentRail');

  /// When the last rail was a saved card, its WLCM cardId token so the same
  /// card is re-selected next time.
  BaseStorage<String?> get lastSavedCardId =>
      BaseStorage(_box, 'lastSavedCardId');

  /// Wipes everything that belongs to the account being left.
  ///
  /// This box outlives the session, so anything not cleared here bleeds into the
  /// *next* person to sign in on this device: they were greeted by the previous
  /// user's name, kept their avatar, and never saw the "add your name" prompt
  /// because the old account had already answered it. Session keys (tokens) and
  /// profile keys (name, child, avatar) and the once-per-user UI flags all go.
  Future<void> logout() async {
    // Session.
    await tokens.set(null);
    await code.set(null);
    await codeHash.set(null);
    await deviceToken.set(null);
    await userId.set(null);
    await userPhone.set(null);

    // Who they were.
    await parentName.set(null);
    await childName.set(null);
    await childAge.set(null);
    await avatarPath.set(null);

    // What they'd bought.
    await hasPremium.set(null);
    await planDiscountPercentage.set(null);
    await lastPaymentRail.set(null);
    await lastSavedCardId.set(null);

    // Once-per-user prompts — the next user hasn't seen them.
    await needsOnboarding.set(null);
    await couponPromoShown.set(null);
    await profilePromptDismissed.set(null);
  }
// BaseStorage<String> get username => BaseStorage(_box, 'username');
//
// BaseStorage<String> get imagePath => BaseStorage(_box, 'imagePath');
//
// BaseStorage<int> get tsjId => BaseStorage(_box, 'tsjId');
//
// BaseStorage<String> get deviceToken => BaseStorage(_box, 'device_token');
}
