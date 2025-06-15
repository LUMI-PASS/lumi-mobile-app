import 'package:founders_academy/feature/home/data/model/afisha/afisha_data.dart';
import 'package:founders_academy/feature/home/data/model/pagination/pagination_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'afisha_response.g.dart';

@JsonSerializable()
class AfishaResponse {
  @JsonKey(name: 'data')
  final List<AfishaData>? afishas;

  @JsonKey(name: 'pagination')
  final PaginationData paginationData;

  const AfishaResponse({
    required this.paginationData,
    this.afishas,
  });

  factory AfishaResponse.fromJson(Map<String, dynamic> json) =>
      _$AfishaResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AfishaResponseToJson(this);
}

@JsonSerializable()
class AfishaItemResponse {
  @JsonKey(name: 'data')
  final AfishaData? afishas;

  const AfishaItemResponse({
    this.afishas,
  });

  factory AfishaItemResponse.fromJson(Map<String, dynamic> json) =>
      _$AfishaItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AfishaItemResponseToJson(this);
}
