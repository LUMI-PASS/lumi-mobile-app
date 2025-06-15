import 'package:json_annotation/json_annotation.dart';

part 'live_stream_data.g.dart';

@JsonSerializable()
class LiveStreamData {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'video_link')
  final String videoLink;
  @JsonKey(name: 'starts_at')
  final String startsAt;
  @JsonKey(name: 'ends_at')
  final String endsAt;
  @JsonKey(name: 'thumbnail')
  final String thumbnail;

  const LiveStreamData({
    required this.id,
    required this.title,
    required this.videoLink,
    required this.startsAt,
    required this.endsAt,
    required this.thumbnail,
  });

  factory LiveStreamData.fromJson(Map<String, dynamic> json) =>
      _$LiveStreamDataFromJson(json);

  Map<String, dynamic> toJson() => _$LiveStreamDataToJson(this);
}
