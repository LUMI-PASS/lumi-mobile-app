// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'afisha_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AfishaData _$AfishaDataFromJson(Map<String, dynamic> json) => AfishaData(
      id: json['_id'] as String,
      name: json['name'] as String?,
      photoUrl: json['image'] as String?,
      price: json['price'] as int?,
      tournamentType: (json['tournament_type'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tournamentDate: json['tournament_date'] as String?,
      registrationDate: json['registration_date'] as String?,
      format: json['format'] as String?,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      isRegistered: json['is_registered'] as bool?,
      count: json['count'] as int?,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$AfishaDataToJson(AfishaData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'image': instance.photoUrl,
      'price': instance.price,
      'tournament_type': instance.tournamentType,
      'tournament_date': instance.tournamentDate,
      'registration_date': instance.registrationDate,
      'format': instance.format,
      'location': instance.location,
      'is_registered': instance.isRegistered,
      'count': instance.count,
      'date': instance.date,
    };
