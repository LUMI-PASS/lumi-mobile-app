import 'package:json_annotation/json_annotation.dart';

part 'pagination_data.g.dart';

@JsonSerializable()
class PaginationData {
  @JsonKey(name: 'total_records')
  final int totalRecords;
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'next_page')
  final int? nextPage;
  @JsonKey(name: 'prev_page')
  final int? prevPage;

  const PaginationData({
    required this.totalRecords,
    required this.currentPage,
    required this.totalPages,
    required this.nextPage,
    required this.prevPage,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) =>
      _$PaginationDataFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationDataToJson(this);
}
