import 'package:json_annotation/json_annotation.dart';

part 'address_data.g.dart';

@JsonSerializable()
class AddressData {
  @JsonKey(name: 'country')
  final String? country;
  @JsonKey(name: 'region')
  final String? region;
  @JsonKey(name: 'district')
  final String? district;
  @JsonKey(name: 'neighborhood')
  final String? neighborhood;

  const AddressData({
    this.country,
    this.region,
    this.district,
    this.neighborhood,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) =>
      _$AddressDataFromJson(json);

  Map<String, dynamic> toJson() => _$AddressDataToJson(this);
}
