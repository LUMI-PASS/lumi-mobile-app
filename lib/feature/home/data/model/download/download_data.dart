import 'package:json_annotation/json_annotation.dart';

part 'download_data.g.dart';

@JsonSerializable()
class DownloadData {
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'url')
  final String url;

  const DownloadData({
    this.name,
    required this.url,
  });

  factory DownloadData.fromJson(Map<String, dynamic> json) =>
      _$DownloadDataFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadDataToJson(this);
}
