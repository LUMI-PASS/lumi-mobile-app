import 'package:json_annotation/json_annotation.dart';

part 'token_data.g.dart';

@JsonSerializable()
class TokenData {
  @JsonKey(name: 'access_token')
  final String token;

  const TokenData({
    required this.token,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) =>
      _$TokenDataFromJson(json["data"]);

  Map<String, dynamic> toJson() => _$TokenDataToJson(this);
}
