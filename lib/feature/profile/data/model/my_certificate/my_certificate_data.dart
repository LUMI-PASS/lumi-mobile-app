import 'package:json_annotation/json_annotation.dart';

part 'my_certificate_data.g.dart';

@JsonSerializable()
class MyCertificateData {
  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'certificate')
  final String? certificate;
  @JsonKey(name: 'course')
  final String? courseTitle;
  @JsonKey(name: 'finished_at')
  final String? finishDate;

  const MyCertificateData({
    required this.id,
    required this.certificate,
    required this.courseTitle,
    required this.finishDate,
  });

  factory MyCertificateData.fromJson(Map<String, dynamic> json) =>
      _$MyCertificateDataFromJson(json);

  Map<String, dynamic> toJson() => _$MyCertificateDataToJson(this);
}
