import 'package:json_annotation/json_annotation.dart';

part 'profile_delete_data.g.dart';

@JsonSerializable()
class ProfileDeleteResponse {
  @JsonKey(name: 'is_deleted')
  final bool isDeleted;

  const ProfileDeleteResponse({
    required this.isDeleted,
  });

  factory ProfileDeleteResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileDeleteResponseFromJson(json["data"] ?? json);

  Map<String, dynamic> toJson() => _$ProfileDeleteResponseToJson(this);
}
