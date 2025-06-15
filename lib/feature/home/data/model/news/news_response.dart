import 'package:lumi_pass/feature/home/data/model/news/news_data.dart';
import 'package:lumi_pass/feature/home/data/model/pagination/pagination_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'news_response.g.dart';

@JsonSerializable()
class NewsResponse {
  @JsonKey(name: 'data')
  final List<NewsData>? news;

  @JsonKey(name: 'pagination')
  final PaginationData paginationData;

  const NewsResponse({
    required this.paginationData,
    this.news,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NewsResponseToJson(this);
}

@JsonSerializable()
class NewsItemResponse {
  @JsonKey(name: 'data')
  final NewsData? news;

  const NewsItemResponse({this.news});

  factory NewsItemResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NewsItemResponseToJson(this);
}
