// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) => ProfileData(
      userId: json['user'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] == null
          ? null
          : AddressData.fromJson(json['address'] as Map<String, dynamic>),
      education: json['education'] == null
          ? null
          : EducationData.fromJson(json['education'] as Map<String, dynamic>),
      image: json['image'] as String?,
      points: json['points'] as int?,
    );

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{
      'user': instance.userId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone_number': instance.phoneNumber,
      'address': instance.address,
      'education': instance.education,
      'image': instance.image,
      'points': instance.points,
    };
