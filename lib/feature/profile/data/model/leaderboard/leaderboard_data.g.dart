// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardData _$LeaderboardDataFromJson(Map<String, dynamic> json) =>
    LeaderboardData(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      image: json['image'] as String?,
      points: json['points'] as int?,
      isCurrentUser: json['is_current_user'] as bool,
      position: json['position'] as int,
    );

Map<String, dynamic> _$LeaderboardDataToJson(LeaderboardData instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'image': instance.image,
      'points': instance.points,
      'is_current_user': instance.isCurrentUser,
      'position': instance.position,
    };
