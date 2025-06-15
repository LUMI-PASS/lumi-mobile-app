import 'package:json_annotation/json_annotation.dart';

part 'enroll_data.g.dart';

@JsonSerializable()
class EnrollData {
  @JsonKey(name: 'course')
  final String course;
  @JsonKey(name: 'user')
  final String user;

  const EnrollData({
    required this.course,
    required this.user,
  });

  factory EnrollData.fromJson(Map<String, dynamic> json) =>
      _$EnrollDataFromJson(json["data"]);

  Map<String, dynamic> toJson() => _$EnrollDataToJson(this);
}
