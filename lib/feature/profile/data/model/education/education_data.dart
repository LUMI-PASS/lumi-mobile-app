import 'package:json_annotation/json_annotation.dart';

part 'education_data.g.dart';

@JsonSerializable()
class EducationData {
  @JsonKey(name: 'organization')
  final String? organization;
  @JsonKey(name: 'region')
  final String? region;
  @JsonKey(name: 'district')
  final String? district;
  @JsonKey(name: 'type')
  final String? type;

  EducationData({
    this.type,
    this.region,
    this.district,
    this.organization,
  });

  factory EducationData.fromJson(Map<String, dynamic> json) =>
      _$EducationDataFromJson(json);

  Map<String, dynamic> toJson() => _$EducationDataToJson(this);
}
