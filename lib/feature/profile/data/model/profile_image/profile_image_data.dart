import 'package:json_annotation/json_annotation.dart';

part 'profile_image_data.g.dart';

@JsonSerializable()
class ProfileImageData {
  @JsonKey(name: 'url')
  final String? url;

  ProfileImageData({
    this.url,
  });

  factory ProfileImageData.fromJson(Map<String, dynamic> json) =>
      _$ProfileImageDataFromJson(json["data"] ?? json);

  Map<String, dynamic> toJson() => _$ProfileImageDataToJson(this);
}
