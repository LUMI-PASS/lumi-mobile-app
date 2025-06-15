import 'package:lumi_pass/feature/home/data/model/download/download_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_data.g.dart';

@JsonSerializable()
class BookData {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'image')
  final String image;
  @JsonKey(name: 'download_link')
  final DownloadData downloadData;
  @JsonKey(name: 'mutolaa_deep_link')
  final String? mutolaaDeepLink;
  @JsonKey(name: 'author')
  final String author;

  const BookData({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.downloadData,
    this.mutolaaDeepLink,
    required this.author,
  });

  factory BookData.fromJson(Map<String, dynamic> json) =>
      _$BookDataFromJson(json);

  Map<String, dynamic> toJson() => _$BookDataToJson(this);
}
