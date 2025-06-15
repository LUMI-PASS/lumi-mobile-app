import 'package:lumi_pass/feature/profile/data/model/my_certificate/my_certificate_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_certificate_response.g.dart';

@JsonSerializable()
class MyCertificateResponse {
  @JsonKey(name: 'data')
  final List<MyCertificateData>? myCertificate;

  MyCertificateResponse({
    this.myCertificate,
  });

  factory MyCertificateResponse.fromJson(Map<String, dynamic> json) =>
      _$MyCertificateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MyCertificateResponseToJson(this);
}
