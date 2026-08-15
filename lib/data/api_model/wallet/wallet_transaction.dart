import 'package:freezed_annotation/freezed_annotation.dart';

import 'wallet_tx_kind.dart';

part 'wallet_transaction.freezed.dart';
part 'wallet_transaction.g.dart';

/// One row of the wallet ledger, from `GET /api/wallet/transactions`.
///
/// [kindRaw] keeps the wire string for (de)serialisation; read [kind] for the
/// typed value, which degrades to [WalletTxKind.unknown] rather than throwing
/// on a value this app version doesn't know about.
@freezed
class WalletTransactionModel with _$WalletTransactionModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory WalletTransactionModel({
    @JsonKey(name: '_id') String? id,
    @JsonKey(name: 'kind') String? kindRaw,

    /// Signed integer soum: positive credits, negative debits.
    @Default(0) num amount,
    @Default(0) num balanceAfter,
    String? orderId,
    String? activityId,

    /// Which of the three earn types produced this, when it was an accrual.
    String? earnType,

    /// Percentage applied at the time — snapshotted, so history doesn't move
    /// when the dashboard changes the rate.
    num? percent,
    num? baseAmount,
    String? status,
    String? note,
    String? createdAt,

    /// The class this entry came from, resolved server-side in the caller's
    /// language. Null on rows with no activity behind them — a manual
    /// adjustment, most obviously.
    String? activityName,

    /// Which sub-course was bought, when the order bought one. Snapshotted on
    /// the order at purchase, so it still names a sub-course that has since
    /// been retired.
    String? subcourseName,

    /// `trial` or `full` on a course order; null on a plain class.
    String? coursePurchase,
  }) = _WalletTransactionModel;

  const WalletTransactionModel._();

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionModelFromJson(json);

  /// Typed kind, never throws. See [WalletTxKind.fromKey].
  WalletTxKind get kind => WalletTxKind.fromKey(kindRaw);

  /// Sign comes from the amount, not the kind — an adjustment goes either way.
  bool get isPositive => amount > 0;

  /// Absolute magnitude, for rendering "+X" / "−X" from a signed value.
  num get magnitude => amount < 0 ? -amount : amount;

  /// Earned but not yet spendable.
  bool get isPending => status == 'pending';

  /// What this entry was FOR, as one line: the class, narrowed to the
  /// sub-course when there is one. Null when the row has no source — the
  /// caller then falls back to naming the kind.
  String? get sourceLabel {
    final activity = activityName?.trim();
    final sub = subcourseName?.trim();
    if (activity == null || activity.isEmpty) {
      return (sub == null || sub.isEmpty) ? null : sub;
    }
    if (sub == null || sub.isEmpty) return activity;
    return '$activity · $sub';
  }

  /// A trial lesson reads differently from a whole-course enrolment, and the
  /// two are priced by separate rules — so the history says which.
  bool get isTrial => coursePurchase == 'trial';

  DateTime? get createdAtDate {
    final raw = createdAt;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
