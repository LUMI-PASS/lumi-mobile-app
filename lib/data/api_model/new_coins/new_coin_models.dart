import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_enums.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';

int _int(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

num _num(Object? v) => v is num ? v : num.tryParse('${v ?? ''}') ?? 0;

DateTime? _date(Object? v) {
  final s = v?.toString();
  if (s == null || s.isEmpty) return null;
  return DateTime.tryParse(s);
}

/// Coins left to pay once a referral voucher took [discount] so'm off a
/// booking that lists at [subtotal] so'm and [coins] coins.
///
/// The server's own sum (`coinsAfterDiscount` in `new-coins.rules.ts`): the
/// voucher's share of the price comes off the coins, rounded DOWN. Kept
/// identical so the figure on the Pay button is the figure that is spent.
int newCoinsAfterDiscount(int coins, num subtotal, num discount) {
  if (coins <= 0 || subtotal <= 0 || discount <= 0) return coins;
  final capped = discount > subtotal ? subtotal : discount;
  final off = (coins * capped / subtotal).floor();
  return off >= coins ? 0 : coins - off;
}

/// What one ticket costs in coins when the server did not say: `ceil(price /
/// rate)`. A display fallback only — the server quotes the booking itself at
/// checkout and its figure is the one that is charged.
int? newCoinPriceFor(num price, num? rate) {
  if (rate == null || rate <= 0 || price <= 0) return null;
  return (price / rate).ceil();
}

/// A pack of coins on sale.
class NewCoinPack {
  const NewCoinPack({
    required this.id,
    required this.kindKey,
    required this.name,
    this.description,
    required this.price,
    required this.coins,
    required this.validDays,
    this.pricePerCoin,
    this.currency = 'UZS',
  });

  final String id;

  /// The raw `kind`, kept for (de)serialization — read [kind].
  final String kindKey;

  /// Already localized by the server from the `lang` header.
  final String name;
  final String? description;

  /// What the pack costs, in so'm.
  final num price;
  final int coins;

  /// How long the coins live from the day they are bought. 0 when the pack
  /// carries no deadline.
  final int validDays;

  /// `price / coins`, rounded by the server. Null on a pack with no coins.
  final num? pricePerCoin;
  final String currency;

  NewCoinPackKind get kind => NewCoinPackKind.fromKey(kindKey);

  factory NewCoinPack.fromJson(Map<String, dynamic> json) {
    final description = json['description']?.toString();
    return NewCoinPack(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      kindKey: json['kind']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description:
          description != null && description.isNotEmpty ? description : null,
      price: _num(json['price']),
      coins: _int(json['coins']),
      validDays: _int(json['valid_days']),
      pricePerCoin:
          json['price_per_coin'] is num ? json['price_per_coin'] as num : null,
      currency: json['currency']?.toString() ?? 'UZS',
    );
  }
}

/// Everything the "Lumi Coin" screen sells, in one read (`new-coins/packs`).
class NewCoinCatalogue {
  const NewCoinCatalogue({
    this.main = const [],
    this.extra = const [],
    this.activityRate = 0,
    this.canBuyExtras = false,
    this.firstPackBonus = 0,
  });

  static const empty = NewCoinCatalogue();

  final List<NewCoinPack> main;
  final List<NewCoinPack> extra;

  /// So'm per coin when paying for an activity (`ceil(price / rate)`).
  final num activityRate;

  /// Extras are sold only on top of a live main pack — one BOUGHT and not
  /// yet expired, by the server's own rule.
  final bool canBuyExtras;

  /// Coins added to the buyer's FIRST main pack. 0 means there is nothing
  /// to advertise — the bonus is off, or this buyer already had it.
  final int firstPackBonus;

  /// The whole feature hangs off this: with no main pack on sale there is
  /// no way into the system, so nothing about it is shown anywhere.
  bool get isOnSale => main.isNotEmpty;

  /// The packs a booking [missing] coins short may be topped up with,
  /// cheapest first. Coins are always bought as a whole pack, and only packs
  /// holding at least [missing] coins are offered — one that would leave the
  /// booking short is not:
  ///
  /// * without a live main pack (never bought, or expired): main packs;
  /// * with one ([canBuyExtras]): extra packs — or, when no extra is big
  ///   enough, the main packs that are (a tariff change, which carries the
  ///   unspent coins over).
  ///
  /// Empty only when no pack at all is big enough.
  List<NewCoinPack> topUpPacks(int missing) {
    List<NewCoinPack> fitting(List<NewCoinPack> packs) =>
        packs.where((p) => p.coins >= missing).toList()
          ..sort((a, b) => a.price.compareTo(b.price));
    if (canBuyExtras) {
      final extras = fitting(extra);
      if (extras.isNotEmpty) return extras;
    }
    return fitting(main);
  }

  factory NewCoinCatalogue.fromJson(Map<String, dynamic> json) {
    List<NewCoinPack> packs(Object? raw) => ((raw as List?) ?? const [])
        .whereType<Map>()
        .map((e) => NewCoinPack.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return NewCoinCatalogue(
      main: packs(json['main']),
      extra: packs(json['extra']),
      activityRate: _num(json['activity_rate']),
      canBuyExtras: json['can_buy_extras'] == true,
      firstPackBonus: _int(json['first_pack_bonus']),
    );
  }
}

/// One batch of held coins with its own deadline.
class NewCoinLot {
  const NewCoinLot({
    required this.id,
    required this.kindKey,
    required this.coinsTotal,
    required this.coinsLeft,
    this.expiresAt,
    this.purchasedAt,
    this.status = '',
  });

  final String id;

  /// The raw `kind`, kept for (de)serialization — read [kind].
  final String kindKey;
  final int coinsTotal;
  final int coinsLeft;

  /// Null on coins that never expire (loose coins).
  final DateTime? expiresAt;
  final DateTime? purchasedAt;
  final String status;

  NewCoinLotKind get kind => NewCoinLotKind.fromKey(kindKey);

  factory NewCoinLot.fromJson(Map<String, dynamic> json) => NewCoinLot(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        kindKey: json['kind']?.toString() ?? '',
        coinsTotal: _int(json['coins_total']),
        coinsLeft: _int(json['coins_left']),
        expiresAt: _date(json['expires_at']),
        purchasedAt: _date(json['purchased_at']),
        status: json['status']?.toString() ?? '',
      );
}

/// The coins a user holds (`new-coins/balance`).
class NewCoinBalance {
  const NewCoinBalance({
    this.balance = 0,
    this.hasActiveMain = false,
    this.activeMainPackId,
    this.activeMainExpiresAt,
    this.nearestExpiry,
    this.nearestExpiryCoins = 0,
    this.lots = const [],
  });

  static const empty = NewCoinBalance();

  final int balance;
  final bool hasActiveMain;

  /// The pack the live main pack — the current tariff — was bought as. Null
  /// without one, or from a server that does not send it yet.
  final String? activeMainPackId;

  /// When the current tariff runs out. Null without one.
  final DateTime? activeMainExpiresAt;

  /// The soonest deadline among the coins still held, and how many it takes.
  final DateTime? nearestExpiry;
  final int nearestExpiryCoins;

  /// Already sorted soonest-expiring first by the server.
  final List<NewCoinLot> lots;

  factory NewCoinBalance.fromJson(Map<String, dynamic> json) => NewCoinBalance(
        balance: _int(json['balance']),
        hasActiveMain: json['has_active_main'] == true,
        activeMainPackId: json['has_active_main'] == true
            ? json['active_main_pack_id']?.toString()
            : null,
        activeMainExpiresAt: _date(json['active_main_expires_at']),
        nearestExpiry: _date(json['nearest_expiry']),
        nearestExpiryCoins: _int(json['nearest_expiry_coins']),
        lots: ((json['lots'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => NewCoinLot.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

/// One row of the coin ledger.
class NewCoinTransaction {
  const NewCoinTransaction({
    required this.id,
    required this.kindKey,
    required this.amount,
    required this.balanceAfter,
    this.orderId,
    this.activityId,
    this.note,
    this.createdAt,
    this.orderTypeKey,
    this.refunded = false,
    this.activityNames,
    this.branchName,
    this.ticketDate,
    this.startTime,
    this.tickets,
    this.shopOrderId,
    this.itemNames,
    this.itemCount,
    this.packNames,
  });

  final String id;

  /// The raw `kind`, kept for (de)serialization — read [kind].
  final String kindKey;

  /// Signed: positive when coins came in, negative when they went out.
  final int amount;
  final int balanceAfter;
  final String? orderId;
  final String? activityId;
  final String? note;
  final DateTime? createdAt;

  // What the row was for — named by the server from the order or the pack
  // behind it. All optional: an older server sends none of them.

  /// The raw `order_type` — read [orderType].
  final String? orderTypeKey;

  /// A spend whose coins have since been given back.
  final bool refunded;

  /// `{uz, ru, en}` — read [activityName].
  final Map<String, dynamic>? activityNames;
  final String? branchName;

  /// The first lesson the spend paid for, as the server stores it
  /// (`YYYY-MM-DD`, `HH:mm`).
  final String? ticketDate;
  final String? startTime;

  /// How many tickets the order holds.
  final int? tickets;

  /// The shop order's own id — what `ShopOrderRoute` opens by.
  final String? shopOrderId;

  /// `{uz, ru, en}` of the first item — read [itemName].
  final Map<String, dynamic>? itemNames;
  final int? itemCount;

  /// `{uz, ru, en}` — read [packName].
  final Map<String, dynamic>? packNames;

  NewCoinTransactionKind get kind => NewCoinTransactionKind.fromKey(kindKey);

  NewCoinOrderType get orderType => NewCoinOrderType.fromKey(orderTypeKey);

  String? get activityName => _localized(activityNames);
  String? get itemName => _localized(itemNames);
  String? get packName => _localized(packNames);

  /// The lesson's date and time, when the server named one.
  DateTime? get lessonAt {
    final date = DateTime.tryParse(ticketDate ?? '');
    if (date == null) return null;
    final hm = (startTime ?? '').split(':');
    final h = hm.isNotEmpty ? int.tryParse(hm[0]) : null;
    final m = hm.length > 1 ? int.tryParse(hm[1]) : null;
    return DateTime(date.year, date.month, date.day, h ?? 0, m ?? 0);
  }

  factory NewCoinTransaction.fromJson(Map<String, dynamic> json) {
    String? nonEmpty(Object? v) {
      final s = v?.toString();
      return (s != null && s.isNotEmpty) ? s : null;
    }

    return NewCoinTransaction(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      kindKey: json['kind']?.toString() ?? '',
      amount: _int(json['amount']),
      balanceAfter: _int(json['balance_after']),
      orderId: nonEmpty(json['order_id']),
      activityId: nonEmpty(json['activity_id']),
      note: nonEmpty(json['note']),
      createdAt: _date(json['created_at']),
      orderTypeKey: nonEmpty(json['order_type']),
      refunded: json['refunded'] == true,
      activityNames: _map(json['activity_name']),
      branchName: nonEmpty(json['branch_name']),
      ticketDate: nonEmpty(json['ticket_date']),
      startTime: nonEmpty(json['start_time']),
      tickets: json['tickets'] == null ? null : _int(json['tickets']),
      shopOrderId: nonEmpty(json['shop_order_id']),
      itemNames: _map(json['item_name']),
      itemCount: json['item_count'] == null ? null : _int(json['item_count']),
      packNames: _map(json['pack_name']),
    );
  }
}

Map<String, dynamic>? _map(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

/// The app's language first, then any language that has the name.
String? _localized(Map<String, dynamic>? names) {
  if (names == null) return null;
  for (final key in [currentLang, 'ru', 'uz', 'en']) {
    final v = names[key];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return null;
}

/// One page of the ledger (`new-coins/transactions`). Unlike its siblings this
/// endpoint is NOT wrapped a second time: `data` is the list itself and `meta`
/// sits beside it.
class NewCoinTransactionPage {
  const NewCoinTransactionPage({
    this.items = const [],
    this.page = 1,
    this.limit = 20,
    this.total = 0,
  });

  final List<NewCoinTransaction> items;
  final int page;
  final int limit;
  final int total;

  bool get hasMore => page * limit < total;

  factory NewCoinTransactionPage.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : const <String, dynamic>{};
    return NewCoinTransactionPage(
      items: ((json['data'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => NewCoinTransaction.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      page: meta['page'] == null ? 1 : _int(meta['page']),
      limit: meta['limit'] == null ? 20 : _int(meta['limit']),
      total: _int(meta['total']),
    );
  }
}

/// The answer to buying a pack or loose coins.
///
/// [checkout] is the same [CheckoutResult] every other purchase returns — the
/// order is an ordinary one for the saved-card, card-OTP and status-polling
/// endpoints — and the rest says what the order will mint once it is paid.
/// Nothing is credited until the payment confirms.
class NewCoinPurchaseResult {
  const NewCoinPurchaseResult({
    required this.checkout,
    this.kindKey = '',
    this.coins = 0,
    this.validDays = 0,
  });

  final CheckoutResult checkout;

  /// `main` / `extra` for a pack, `single` for loose coins.
  final String kindKey;
  final int coins;
  final int validDays;

  NewCoinLotKind get kind => NewCoinLotKind.fromKey(kindKey);

  factory NewCoinPurchaseResult.fromJson(Map<String, dynamic> json) =>
      NewCoinPurchaseResult(
        checkout: CheckoutResult.fromJson(json),
        kindKey: json['kind']?.toString() ?? '',
        coins: _int(json['coins']),
        validDays: _int(json['valid_days']),
      );
}

/// How far short a coin balance fell — the body of an
/// `insufficient_new_coins` refusal, or the same sum worked out locally.
class NewCoinShortfall {
  const NewCoinShortfall({
    required this.required,
    required this.available,
    required this.missing,
  });

  final int required;
  final int available;
  final int missing;

  factory NewCoinShortfall.of({required int required, required int available}) {
    final missing = required - available;
    return NewCoinShortfall(
      required: required,
      available: available,
      missing: missing < 0 ? 0 : missing,
    );
  }

  /// Reads the refusal body. `missing` is recomputed when the server left it
  /// out, so the sheet always has a number to offer.
  factory NewCoinShortfall.fromJson(Map<String, dynamic> json) {
    final required = _int(json['required']);
    final available = _int(json['available']);
    final computed = required - available;
    return NewCoinShortfall(
      required: required,
      available: available,
      missing: json['missing'] == null
          ? (computed < 0 ? 0 : computed)
          : _int(json['missing']),
    );
  }

  /// The shortfall carried by an error body, or null when the body is not an
  /// `insufficient_new_coins` refusal.
  static NewCoinShortfall? fromResponse(dynamic data) {
    if (NewCoinErrorCode.fromResponse(data) != NewCoinErrorCode.insufficient) {
      return null;
    }
    return NewCoinShortfall.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
