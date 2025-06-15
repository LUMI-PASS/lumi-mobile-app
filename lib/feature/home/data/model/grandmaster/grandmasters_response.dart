import 'package:lumi_pass/feature/home/data/model/grandmaster/grandmaster_data.dart';
import 'package:lumi_pass/feature/home/data/model/pagination/pagination_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grandmasters_response.g.dart';

@JsonSerializable()
class GrandmastersResponse {
  @JsonKey(name: 'data')
  final List<GrandmasterData>? grandmasters;

  @JsonKey(name: 'pagination')
  final PaginationData paginationData;

  const GrandmastersResponse({
    required this.paginationData,
    this.grandmasters,
  });

  factory GrandmastersResponse.fromJson(Map<String, dynamic> json) =>
      _$GrandmastersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GrandmastersResponseToJson(this);
}

@JsonSerializable()
class GrandmasterResponse {
  @JsonKey(name: 'data')
  final GrandmasterData? grandmaster;

  const GrandmasterResponse({this.grandmaster});

  factory GrandmasterResponse.fromJson(Map<String, dynamic> json) =>
      _$GrandmasterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GrandmasterResponseToJson(this);
}
