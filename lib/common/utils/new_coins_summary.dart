import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';

/// What the whole app needs to know about "Lumi Coin", published by
/// `AppCubit`: is it on sale, and what does this user hold.
///
/// One value every screen watches rather than a fetch per screen, for the
/// reason the promo packet is: it decides what RENDERS — the profile tile, the
/// coin price beside a so'm price, the coin option at checkout — and those
/// have to change together the moment a pack is bought or a booking is paid.
class NewCoinsSummary {
  const NewCoinsSummary({
    this.onSale = false,
    this.balance = 0,
    this.hasActiveMain = false,
    this.nearestExpiry,
    this.nearestExpiryCoins = 0,
    this.canBuyExtras = false,
    this.singleCoinPrice = 0,
    this.activityRate = 0,
    this.mainPacks = const [],
    this.activeMainPackId,
    this.activeMainExpiresAt,
  });

  /// At least one main pack is on sale.
  final bool onSale;
  final int balance;
  final bool hasActiveMain;
  final DateTime? nearestExpiry;
  final int nearestExpiryCoins;

  /// Extras and loose coins are sold only on top of a live main pack.
  final bool canBuyExtras;

  /// Unit price of one loose coin, in so'm.
  final num singleCoinPrice;

  /// So'm per coin when paying for an activity.
  final num activityRate;

  /// The main packs on sale, in shelf order — what [currentPack] is looked
  /// up in, and what gives it its colour.
  final List<NewCoinPack> mainPacks;

  /// The pack the live tariff was bought as, and when it runs out.
  final String? activeMainPackId;
  final DateTime? activeMainExpiresAt;

  /// The buyer's tariff, when they hold one and it is still on the shelf.
  NewCoinPack? get currentPack {
    final i = currentPackIndex;
    return i < 0 ? null : mainPacks[i];
  }

  /// Where [currentPack] sits on the shelf, or -1.
  int get currentPackIndex => activeMainPackId == null
      ? -1
      : mainPacks.indexWhere((p) => p.id == activeMainPackId);

  /// The gate on every coin surface in the app.
  ///
  /// With no main pack on sale there is no way into the system, so the
  /// feature stays invisible — the backend is live before any pack exists.
  /// Someone still HOLDING coins keeps seeing it regardless: taking a pack off
  /// sale must not strand a balance that was paid for.
  bool get isVisible => onSale || balance > 0;

  /// Loose coins can be bought right now: they are priced, and this user holds
  /// the main pack they are sold on top of.
  bool get canBuySingle => canBuyExtras && singleCoinPrice > 0;

  NewCoinsSummary withCatalogue(NewCoinCatalogue catalogue) => NewCoinsSummary(
        onSale: catalogue.isOnSale,
        balance: balance,
        hasActiveMain: hasActiveMain,
        nearestExpiry: nearestExpiry,
        nearestExpiryCoins: nearestExpiryCoins,
        canBuyExtras: catalogue.canBuyExtras,
        singleCoinPrice: catalogue.singleCoinPrice,
        activityRate: catalogue.activityRate,
        mainPacks: catalogue.main,
        activeMainPackId: activeMainPackId,
        activeMainExpiresAt: activeMainExpiresAt,
      );

  NewCoinsSummary withBalance(NewCoinBalance held) => NewCoinsSummary(
        onSale: onSale,
        balance: held.balance,
        hasActiveMain: held.hasActiveMain,
        nearestExpiry: held.nearestExpiry,
        nearestExpiryCoins: held.nearestExpiryCoins,
        canBuyExtras: canBuyExtras,
        singleCoinPrice: singleCoinPrice,
        activityRate: activityRate,
        mainPacks: mainPacks,
        activeMainPackId: held.activeMainPackId,
        activeMainExpiresAt: held.activeMainExpiresAt,
      );

  /// What is left once the account signs out: the shelf, with nobody's coins
  /// on it.
  NewCoinsSummary signedOut() => NewCoinsSummary(
        onSale: onSale,
        singleCoinPrice: singleCoinPrice,
        activityRate: activityRate,
        mainPacks: mainPacks,
      );

  @override
  bool operator ==(Object other) =>
      other is NewCoinsSummary &&
      other.onSale == onSale &&
      other.balance == balance &&
      other.hasActiveMain == hasActiveMain &&
      other.nearestExpiry == nearestExpiry &&
      other.nearestExpiryCoins == nearestExpiryCoins &&
      other.canBuyExtras == canBuyExtras &&
      other.singleCoinPrice == singleCoinPrice &&
      other.activityRate == activityRate &&
      other.activeMainPackId == activeMainPackId &&
      other.activeMainExpiresAt == activeMainExpiresAt &&
      _packsKey(other.mainPacks) == _packsKey(mainPacks);

  /// What of the shelf this summary shows: which packs, under which names.
  static String _packsKey(List<NewCoinPack> packs) =>
      packs.map((p) => '${p.id}:${p.name}').join('|');

  @override
  int get hashCode => Object.hash(
        onSale,
        balance,
        hasActiveMain,
        nearestExpiry,
        nearestExpiryCoins,
        canBuyExtras,
        singleCoinPrice,
        activityRate,
        activeMainPackId,
        activeMainExpiresAt,
        _packsKey(mainPacks),
      );
}
