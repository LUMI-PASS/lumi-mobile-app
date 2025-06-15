// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboards_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardResponse _$LeaderboardResponseFromJson(Map<String, dynamic> json) =>
    LeaderboardResponse(
      user: LeaderboardData.fromJson(json['user'] as Map<String, dynamic>),
      leaderboard: (json['data'] as List<dynamic>?)
          ?.map((e) => LeaderboardData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LeaderboardResponseToJson(
        LeaderboardResponse instance) =>
    <String, dynamic>{
      'data': instance.leaderboard,
      'user': instance.user,
    };
