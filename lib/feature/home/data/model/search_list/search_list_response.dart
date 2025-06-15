import 'package:lumi_pass/feature/home/data/model/search_list/search_list_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_list_response.g.dart';

@JsonSerializable()
class SearchListResponse {
  @JsonKey(name: 'data')
  final SearchListData? searchList;

  const SearchListResponse({this.searchList});

  factory SearchListResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchListResponseToJson(this);
}
