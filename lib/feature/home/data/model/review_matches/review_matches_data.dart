import 'package:json_annotation/json_annotation.dart';

part 'review_matches_data.g.dart';

@JsonSerializable()
class ReviewMatchData {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'thumbnail')
  final String thumbnailUrl;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(name: 'youtube_link')
  final String youtubeLink;
  @JsonKey(name: 'date')
  final String date;

  const ReviewMatchData({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.description,
    required this.shortDescription,
    required this.youtubeLink,
    required this.date,
  });

  factory ReviewMatchData.fromJson(Map<String, dynamic> json) =>
      _$ReviewMatchDataFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewMatchDataToJson(this);
}
