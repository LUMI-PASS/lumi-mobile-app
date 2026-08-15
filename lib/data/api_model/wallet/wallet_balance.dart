import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_balance.freezed.dart';
part 'wallet_balance.g.dart';

/// The user's wallet totals, from `GET /api/wallet`.
///
/// Three counters move independently, which is why they're all carried rather
/// than collapsed into one number:
///  • [balance] — matured money, before reservations;
///  • [heldBalance] — reserved by an order that hasn't been paid yet;
///  • [pendingBalance] — earned but not yet matured, not spendable.
///
/// [available] is what the user may actually spend and is the number the UI
/// leads with. The server sends it too; the local getter is the fallback for an
/// older payload.
@freezed
class WalletBalance with _$WalletBalance {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory WalletBalance({
    @Default(0) num balance,
    @Default(0) num pendingBalance,
    @Default(0) num heldBalance,
    @JsonKey(name: 'available') num? availableRaw,
    @Default(0) num lifetimeEarned,
    @Default(0) num lifetimeSpent,
    @Default(false) bool isFrozen,
    @Default('UZS') String currency,
  }) = _WalletBalance;

  const WalletBalance._();

  factory WalletBalance.fromJson(Map<String, dynamic> json) =>
      _$WalletBalanceFromJson(json);

  /// Spendable right now. Clamped at zero — a reservation must never render as
  /// a negative balance.
  num get available {
    final raw = availableRaw;
    if (raw != null) return raw < 0 ? 0 : raw;
    final computed = balance - heldBalance;
    return computed < 0 ? 0 : computed;
  }

  /// Whether there's anything at all to show beyond an empty state.
  bool get hasMoney =>
      available > 0 || pendingBalance > 0 || heldBalance > 0;
}
