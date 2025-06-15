import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_data.g.dart';

@JsonSerializable()
class LeaderboardData {
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'image')
  final String? image;
  @JsonKey(name: 'points')
  final int? points;
  @JsonKey(name: 'is_current_user')
  final bool isCurrentUser;
  @JsonKey(name: 'position')
  final int position;

  const LeaderboardData({
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.points,
    required this.isCurrentUser,
    required this.position,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardDataFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardDataToJson(this);
}
