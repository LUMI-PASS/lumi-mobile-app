import 'package:json_annotation/json_annotation.dart';

part 'profile_delete_reason_data.g.dart';

@JsonSerializable()
class ProfileDeleteReasonData {
  @JsonKey(name: 'type')
  final String type;
  @JsonKey(name: 'body')
  final String body;

  const ProfileDeleteReasonData({
    required this.type,
    required this.body,
  });

  factory ProfileDeleteReasonData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDeleteReasonDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDeleteReasonDataToJson(this);
}
