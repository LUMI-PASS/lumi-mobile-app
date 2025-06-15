import 'package:json_annotation/json_annotation.dart';

part 'grandmaster_bot_data.g.dart';

@JsonSerializable()
class GrandmasterBotData {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'bots')
  final List<BotData>? bots;

  GrandmasterBotData({
    this.id,
    this.name,
    this.bots,
  });

  factory GrandmasterBotData.fromJson(Map<String, dynamic> json) =>
      _$GrandmasterBotDataFromJson(json);

  Map<String, dynamic> toJson() => _$GrandmasterBotDataToJson(this);
}

@JsonSerializable()
class BotData {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(name: 'full_name')
  final String? fullName;

  @JsonKey(name: 'image')
  final String? image;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'bot_link')
  final String? botLink;

  @JsonKey(name: 'rating')
  final int? rating;

  BotData({
    this.id,
    this.fullName,
    this.image,
    this.description,
    this.botLink,
    this.rating,
  });

  factory BotData.fromJson(Map<String, dynamic> json) =>
      _$BotDataFromJson(json);

  Map<String, dynamic> toJson() => _$BotDataToJson(this);
}
