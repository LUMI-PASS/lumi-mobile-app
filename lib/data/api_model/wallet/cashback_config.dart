import 'package:freezed_annotation/freezed_annotation.dart';

part 'cashback_config.freezed.dart';
part 'cashback_config.g.dart';

/// One earn type's rate, from `GET /api/cashback/config`.
///
/// The server already folds "feature off", "rule inactive" and "rule absent"
/// into `percent: 0`, so the app only has to check one number to decide whether
/// to show a cashback badge.
@freezed
class CashbackRule with _$CashbackRule {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CashbackRule({
    @Default(0) num percent,
    @Default(false) bool isActive,
    num? maxCashbackAmount,
    @Default(0) num minOrderAmount,
  }) = _CashbackRule;

  const CashbackRule._();

  factory CashbackRule.fromJson(Map<String, dynamic> json) =>
      _$CashbackRuleFromJson(json);

  /// Whether this rate is worth showing to the user at all.
  bool get isVisible => isActive && percent > 0;
}

/// Public cashback configuration.
///
/// Read rather than hardcoded so a dashboard percentage change is picked up
/// without an app release. Every field degrades to "off", so a failed or
/// unparsable fetch simply hides the cashback UI instead of breaking a screen.
@freezed
class CashbackConfig with _$CashbackConfig {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CashbackConfig({
    @Default(false) bool isEnabled,
    @Default(100) num maxRedeemPercent,
    @Default('UZS') String currency,
    @Default(CashbackRules()) CashbackRules rules,
  }) = _CashbackConfig;

  const CashbackConfig._();

  factory CashbackConfig.fromJson(Map<String, dynamic> json) =>
      _$CashbackConfigFromJson(json);

  /// Whether any cashback surface should render at all.
  bool get hasAnyRate =>
      isEnabled &&
      (rules.activity.isVisible ||
          rules.trialLesson.isVisible ||
          rules.course.isVisible);
}

/// The three server-defined earn types. A fixed set, so a class rather than a
/// map — adding a fourth is a deliberate change here and at every read site.
@freezed
class CashbackRules with _$CashbackRules {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CashbackRules({
    @Default(CashbackRule()) CashbackRule activity,
    @Default(CashbackRule()) CashbackRule trialLesson,
    @Default(CashbackRule()) CashbackRule course,
  }) = _CashbackRules;

  factory CashbackRules.fromJson(Map<String, dynamic> json) =>
      _$CashbackRulesFromJson(json);
}
