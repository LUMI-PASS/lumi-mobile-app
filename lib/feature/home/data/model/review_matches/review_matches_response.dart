import 'package:lumi_pass/feature/home/data/model/pagination/pagination_data.dart';
import 'package:lumi_pass/feature/home/data/model/review_matches/review_matches_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_matches_response.g.dart';

@JsonSerializable()
class ReviewMatchesResponse {
  @JsonKey(name: 'data')
  final List<ReviewMatchData>? reviewMatches;

  @JsonKey(name: 'pagination')
  final PaginationData paginationData;

  const ReviewMatchesResponse({
    required this.paginationData,
    this.reviewMatches,
  });

  factory ReviewMatchesResponse.fromJson(Map<String, dynamic> json) =>
      _$ReviewMatchesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewMatchesResponseToJson(this);
}

@JsonSerializable()
class ReviewMatchResponse {
  @JsonKey(name: 'data')
  final ReviewMatchData? reviewMatches;

  const ReviewMatchResponse({this.reviewMatches});

  factory ReviewMatchResponse.fromJson(Map<String, dynamic> json) =>
      _$ReviewMatchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewMatchResponseToJson(this);
}
