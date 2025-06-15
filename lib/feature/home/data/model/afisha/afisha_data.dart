import 'package:founders_academy/feature/home/data/model/afisha/location_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'afisha_data.g.dart';

@JsonSerializable()
class AfishaData {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'image')
  final String? photoUrl;
  @JsonKey(name: 'price')
  final int? price;
  @JsonKey(name: 'tournament_type')
  final List<String>? tournamentType;
  @JsonKey(name: 'tournament_date')
  final String? tournamentDate;
  @JsonKey(name: 'registration_date')
  final String? registrationDate;
  @JsonKey(name: 'format')
  final String? format;
  @JsonKey(name: 'location')
  final Location? location;
  @JsonKey(name: 'is_registered')
  final bool? isRegistered;
  @JsonKey(name: 'count')
  final int? count;
  @JsonKey(name: 'date')
  final String? date;

  const AfishaData(
      {required this.id,
      required this.name,
      required this.photoUrl,
      required this.price,
      required this.tournamentType,
      required this.tournamentDate,
      required this.registrationDate,
      required this.format,
      required this.location,
      required this.isRegistered,
      required this.count,
      required this.date});

  factory AfishaData.fromJson(Map<String, dynamic> json) =>
      _$AfishaDataFromJson(json);

  Map<String, dynamic> toJson() => _$AfishaDataToJson(this);
}
