import 'package:json_annotation/json_annotation.dart';

part 'playlist_data.g.dart';

@JsonSerializable()
class PlaylistData {
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'short_description')
  final String shortDescription;
  @JsonKey(name: 'youtube_link')
  final String youtubeLink;

  const PlaylistData({
    required this.title,
    required this.shortDescription,
    required this.youtubeLink,
  });

  factory PlaylistData.fromJson(Map<String, dynamic> json) =>
      _$PlaylistDataFromJson(json);

  Map<String, dynamic> toJson() => _$PlaylistDataToJson(this);
}
