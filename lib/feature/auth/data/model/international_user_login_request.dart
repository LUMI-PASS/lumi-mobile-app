import 'package:json_annotation/json_annotation.dart';

part 'international_user_login_request.g.dart';

@JsonSerializable()
class InternationalUserLoginRequest {
  @JsonKey(name: 'email')
  final String email;

  InternationalUserLoginRequest({
    required this.email,
  });

  factory InternationalUserLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$InternationalUserLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InternationalUserLoginRequestToJson(this);
}
