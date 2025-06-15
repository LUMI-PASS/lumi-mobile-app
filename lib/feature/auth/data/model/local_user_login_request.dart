import 'package:json_annotation/json_annotation.dart';

part 'local_user_login_request.g.dart';

@JsonSerializable()
class LocalUserLoginRequest {
  @JsonKey(name: 'phone_number')
  final String phoneNumber;

  LocalUserLoginRequest({
    required this.phoneNumber,
  });

  factory LocalUserLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LocalUserLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LocalUserLoginRequestToJson(this);
}
