import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:lumi_pass/data/api_model/wallet/cashback_earn_type.dart';

part 'cashback_preview.freezed.dart';
part 'cashback_preview.g.dart';

/// What one specific purchase earns, from `GET /api/cashback/preview`.
///
/// Deliberately not computed in the app from [CashbackConfig]. The configured
/// percentage is only a ceiling request: what is actually credited is capped by
/// the partner's commission on that particular class, which the client neither
/// has nor should have. A 10% rule can pay 3.5% on a thin-margin class and
/// nothing at all on a very thin one — so every "N% cashback" or "you'll earn
/// ~X" surface reads this, never the config.
///
/// Every field degrades to "earns nothing", so a failed fetch hides the badge
/// rather than promising money.
@freezed
class CashbackPreview with _$CashbackPreview {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CashbackPreview({
    /// Raw wire value, kept for (de)serialization. Read [earnKind] instead.
    String? earnType,
    @Default(0) num percent,
    @Default(0) num amount,

    /// Per-order ceiling in soum, `null` when uncapped.
    num? maxCashbackAmount,

    /// Orders cheaper than this earn nothing.
    @Default(0) num minOrderAmount,
    @Default('UZS') String currency,
  }) = _CashbackPreview;

  const CashbackPreview._();

  factory CashbackPreview.fromJson(Map<String, dynamic> json) =>
      _$CashbackPreviewFromJson(json);

  /// Which rule priced this preview, [CashbackEarnType.unknown] if the backend
  /// sent something this app doesn't model yet.
  CashbackEarnType get earnKind => CashbackEarnType.fromKey(earnType);

  /// Nothing is earned — hide every cashback surface for this purchase.
  static const none = CashbackPreview();

  /// Whether a rate is worth showing at all. The amount can legitimately be 0
  /// while the percent isn't (an amount-less preview, or a price too small to
  /// round up to a single soum), so the badge keys on the percent.
  bool get hasRate => percent > 0;

  /// Whether an "you'll earn ~X" line has a real number to show.
  bool get hasAmount => amount > 0;
}
