/// Which shelf a coin pack sits on.
///
/// [unknown] is the safe fallback for any `kind` string that isn't (yet)
/// modelled here — the backend can add kinds at any time. Resolve with
/// [NewCoinPackKind.fromKey]; switch exhaustively so a newly added value
/// surfaces as a compile-time warning rather than a runtime surprise.
enum NewCoinPackKind {
  /// The main tariff: a batch of coins with a validity in days. Holding a live
  /// one is what unlocks [extra] packs and loose coins.
  monthly('monthly'),

  /// A short top-up with its own deadline, sold only on top of a live
  /// [monthly] pack.
  extra('extra'),

  unknown('');

  const NewCoinPackKind(this.key);

  /// The raw `kind` string as sent by the backend.
  final String key;

  /// Maps a backend string to a [NewCoinPackKind], returning [unknown] for
  /// null or unrecognised values. Never throws.
  static NewCoinPackKind fromKey(String? key) {
    for (final kind in values) {
      if (kind != unknown && kind.key == key) return kind;
    }
    return unknown;
  }
}

/// Where a batch of held coins came from. A balance is a list of these "lots",
/// each with its own deadline.
enum NewCoinLotKind {
  monthly('monthly'),
  extra('extra'),

  /// Loose coins bought at the unit price. These never expire.
  single('single'),

  /// The first-pack bonus.
  bonus('bonus'),

  /// Credited by Lumi staff.
  grant('grant'),

  unknown('');

  const NewCoinLotKind(this.key);

  final String key;

  /// Never throws — an unmodelled kind resolves to [unknown].
  static NewCoinLotKind fromKey(String? key) {
    for (final kind in values) {
      if (kind != unknown && kind.key == key) return kind;
    }
    return unknown;
  }

  /// The translations.csv key naming this lot in the balance list.
  String get labelKey => switch (this) {
        NewCoinLotKind.monthly => 'new_coins_lot_monthly',
        NewCoinLotKind.extra => 'new_coins_lot_extra',
        NewCoinLotKind.single => 'new_coins_lot_single',
        NewCoinLotKind.bonus => 'new_coins_lot_bonus',
        NewCoinLotKind.grant => 'new_coins_lot_grant',
        NewCoinLotKind.unknown => 'new_coins_lot_other',
      };
}

/// One movement on the coin ledger.
enum NewCoinTransactionKind {
  purchase('purchase'),
  bonus('bonus'),
  spend('spend'),
  expire('expire'),
  grant('grant'),
  revoke('revoke'),
  unknown('');

  const NewCoinTransactionKind(this.key);

  final String key;

  /// Never throws — an unmodelled kind resolves to [unknown].
  static NewCoinTransactionKind fromKey(String? key) {
    for (final kind in values) {
      if (kind != unknown && kind.key == key) return kind;
    }
    return unknown;
  }

  /// The translations.csv key naming this movement in the history list.
  String get labelKey => switch (this) {
        NewCoinTransactionKind.purchase => 'new_coins_tx_purchase',
        NewCoinTransactionKind.bonus => 'new_coins_tx_bonus',
        NewCoinTransactionKind.spend => 'new_coins_tx_spend',
        NewCoinTransactionKind.expire => 'new_coins_tx_expire',
        NewCoinTransactionKind.grant => 'new_coins_tx_grant',
        NewCoinTransactionKind.revoke => 'new_coins_tx_revoke',
        NewCoinTransactionKind.unknown => 'new_coins_tx_other',
      };
}

/// Server-driven coin refusals, sent as `error_code` on a 400.
///
/// [unknown] is the fallback for any code that isn't modelled here; the caller
/// then degrades to whatever it would have shown anyway.
enum NewCoinErrorCode {
  /// An extra pack or loose coins were asked for without a live monthly pack.
  monthlyPackRequired('new_coins_monthly_pack_required'),

  /// The pack was taken off sale between the list loading and the tap.
  packInactive('new_coins_pack_inactive'),

  /// The balance does not cover the booking. Carries `required`, `available`
  /// and `missing` — see `NewCoinShortfall`.
  insufficient('insufficient_new_coins'),

  /// Coins were combined with a promocode, the wallet or a promo pass.
  exclusive('new_coins_exclusive'),

  /// A booking paid with coins cannot be cancelled.
  notCancelable('new_coins_not_cancelable'),

  unknown('');

  const NewCoinErrorCode(this.key);

  /// The raw `error_code` string as sent by the backend.
  final String key;

  /// Never throws — null or an unmodelled code resolves to [unknown].
  static NewCoinErrorCode fromKey(String? key) {
    for (final code in values) {
      if (code != unknown && code.key == key) return code;
    }
    return unknown;
  }

  /// Reads the code off an error body (`DioException.response?.data`).
  static NewCoinErrorCode fromResponse(dynamic data) =>
      fromKey(data is Map ? data['error_code']?.toString() : null);

  /// The translations.csv key for this refusal, or null for [unknown] — which
  /// is not a coin refusal at all and is left to the caller's own handling.
  String? get messageKey => switch (this) {
        NewCoinErrorCode.monthlyPackRequired =>
          'new_coins_err_monthly_required',
        NewCoinErrorCode.packInactive => 'new_coins_err_pack_inactive',
        NewCoinErrorCode.insufficient => 'new_coins_err_insufficient',
        NewCoinErrorCode.exclusive => 'new_coins_err_exclusive',
        NewCoinErrorCode.notCancelable => 'new_coins_not_cancelable',
        NewCoinErrorCode.unknown => null,
      };
}
