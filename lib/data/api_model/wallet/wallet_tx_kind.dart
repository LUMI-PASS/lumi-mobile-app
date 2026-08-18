/// Server-driven wallet ledger entry kinds.
///
/// [unknown] is the safe fallback for any `kind` string that isn't (yet)
/// modelled here — the backend can add new kinds (an expiry sweeper, new
/// adjustment types) without the app throwing, and an unmodelled entry renders
/// as a neutral row rather than crashing the history list. Resolve with
/// [WalletTxKind.fromKey]; switch exhaustively so a newly added value surfaces
/// as a compile-time warning rather than a runtime surprise.
enum WalletTxKind {
  /// Cashback accrued on a paid order.
  earn('earn'),

  /// A pending earn became spendable. Bookkeeping only — carries no amount.
  earnMatured('earn_matured'),

  /// An order was refunded or cancelled; the earn was clawed back.
  earnReversed('earn_reversed'),

  /// Balance reserved by an order that hasn't been paid yet.
  hold('hold'),

  /// A reservation was released because the order was cancelled or expired.
  holdReleased('hold_released'),

  /// A reservation was committed when the order was paid.
  spend('spend'),

  /// A paid order was cancelled and the wallet-funded part came back.
  spendRefunded('spend_refunded'),

  /// Manual correction by support.
  adjustment('adjustment'),

  /// Balance expired unused.
  expired('expired'),

  unknown('');

  const WalletTxKind(this.key);

  /// The raw `kind` string as sent by the backend.
  final String key;

  /// Maps a backend string to a [WalletTxKind], returning [unknown] for null or
  /// unrecognised values. Never throws.
  static WalletTxKind fromKey(String? key) {
    for (final kind in values) {
      if (kind != unknown && kind.key == key) return kind;
    }
    return unknown;
  }

  /// Entries that only reserve or release, leaving the balance untouched.
  ///
  /// These are the one case the history can't render as a plain + or −: they
  /// move money between "available" and "reserved" without changing the
  /// balance. Everything else takes its sign from the entry's signed `amount`
  /// (see [WalletTransactionModel.isPositive]) rather than from the kind —
  /// an [adjustment] in particular can go either way.
  bool get isReservation => this == hold || this == holdReleased;

  /// Bookkeeping-only rows the history should skip: they carry no amount and
  /// describe a state change already reflected by another entry.
  bool get isBookkeeping => this == earnMatured;
}
