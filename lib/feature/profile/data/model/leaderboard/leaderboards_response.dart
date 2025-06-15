import 'package:founders_academy/feature/profile/data/model/leaderboard/leaderboard_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'leaderboards_response.g.dart';

@JsonSerializable()
class LeaderboardResponse {
  @JsonKey(name: 'data')
  final List<LeaderboardData>? leaderboard;

  @JsonKey(name: 'user')
  final LeaderboardData user;

  LeaderboardResponse({
    required this.user,
    this.leaderboard,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LeaderboardResponseToJson(this);
}
