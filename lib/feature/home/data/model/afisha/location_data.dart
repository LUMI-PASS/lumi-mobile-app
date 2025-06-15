import 'package:json_annotation/json_annotation.dart';

part 'location_data.g.dart';

@JsonSerializable()
class Location {
  final String name;
  final String address;

  const Location({
    required this.name,
    required this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
