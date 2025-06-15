import 'package:json_annotation/json_annotation.dart';

part 'grandmaster_data.g.dart';

@JsonSerializable()
class GrandmasterData {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'image')
  final String image;
  @JsonKey(name: 'video_url')
  final String videoUrl;

  const GrandmasterData({
    required this.id,
    required this.fullName,
    required this.description,
    required this.image,
    required this.videoUrl,
  });

  factory GrandmasterData.fromJson(Map<String, dynamic> json) =>
      _$GrandmasterDataFromJson(json);

  Map<String, dynamic> toJson() => _$GrandmasterDataToJson(this);
}
