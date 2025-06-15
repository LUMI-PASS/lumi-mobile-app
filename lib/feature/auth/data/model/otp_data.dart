import 'package:json_annotation/json_annotation.dart';

part 'otp_data.g.dart';

@JsonSerializable()
class OtpData {
  @JsonKey(name: 'code')
  final int? code;
  @JsonKey(name: 'code_hash')
  String codeHash;
  @JsonKey(name: 'phone_number')
  String? phoneNumber;
  @JsonKey(name: 'email')
  String? email;

  OtpData({
    this.code,
    required this.codeHash,
    this.phoneNumber,
    this.email,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) =>
      _$OtpDataFromJson(json["data"] ?? json);

  Map<String, dynamic> toJson() => _$OtpDataToJson(this);

  set updateCodeHash(String newCodeHash) {
    codeHash = newCodeHash;
  }
}
