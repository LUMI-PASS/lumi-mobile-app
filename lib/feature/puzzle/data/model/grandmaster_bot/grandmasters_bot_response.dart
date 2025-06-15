import 'package:founders_academy/feature/puzzle/data/model/grandmaster_bot/grandmaster_bot_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'grandmasters_bot_response.g.dart';

@JsonSerializable()
class GrandMasterBotResponse {
  @JsonKey(name: 'data')
  final List<GrandmasterBotData>? grandmasterBotData;

  const GrandMasterBotResponse({required this.grandmasterBotData});

  factory GrandMasterBotResponse.fromJson(Map<String, dynamic> json) =>
      _$GrandMasterBotResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GrandMasterBotResponseToJson(this);
}
