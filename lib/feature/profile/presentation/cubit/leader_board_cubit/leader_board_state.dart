import 'package:lumi_pass/feature/profile/data/model/leaderboard/leaderboard_data.dart';

sealed class LeaderboardState {
  const LeaderboardState();
}

class LeaderboardInitState extends LeaderboardState {
  const LeaderboardInitState();
}

class LeaderboardLoadedState extends LeaderboardState {
  final List<LeaderboardData> leaderboardData;
  final LeaderboardData currentUser;

  LeaderboardLoadedState(this.leaderboardData, this.currentUser);
}

class LeaderboardErrorState extends LeaderboardState {
  const LeaderboardErrorState();
}
