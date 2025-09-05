import 'package:freezed_annotation/freezed_annotation.dart';

part 'tariff_model.freezed.dart';

part 'tariff_model.g.dart';

@freezed
class Tariff with _$Tariff {
  const factory Tariff({
    String? id,
    String? title,
    String? description,
    int? price,
    int? coins,
    @JsonKey(name: 'valid_days') int? validDays,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Tariff;

  factory Tariff.fromJson(Map<String, dynamic> json) => _$TariffFromJson(json);
}
