import 'package:json_annotation/json_annotation.dart';

part 'news_data.g.dart';

@JsonSerializable()
class NewsData {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'content')
  final String content;
  @JsonKey(name: 'short_description')
  final String shortDescription;
  @JsonKey(name: 'image')
  final String imageUrl;
  @JsonKey(name: 'date')
  final String date;

  const NewsData({
    required this.id,
    required this.title,
    required this.content,
    required this.shortDescription,
    required this.imageUrl,
    required this.date,
  });

  factory NewsData.fromJson(Map<String, dynamic> json) =>
      _$NewsDataFromJson(json);

  Map<String, dynamic> toJson() => _$NewsDataToJson(this);
}
