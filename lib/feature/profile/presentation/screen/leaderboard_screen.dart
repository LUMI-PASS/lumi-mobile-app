import 'package:auto_route/auto_route.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart'; // Import the package
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/profile/data/model/leaderboard/leaderboard_data.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/leader_board_cubit/leader_board_cubit.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/leader_board_cubit/leader_board_state.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initial data fetch for the first tab
    _fetchLeaderboardData(0);

    // Listen for tab changes to fetch leaderboard data
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchLeaderboardData(_tabController.index);
      }
    });
  }

  // Function to fetch leaderboard data based on index
  void _fetchLeaderboardData(int index) {
    switch (index) {
      case 0:
        context.read<LeaderBoardCubit>().changePeriod('weekly');
        break;
      case 1:
        context.read<LeaderBoardCubit>().changePeriod('monthly');
        break;
      case 2:
        context.read<LeaderBoardCubit>().changePeriod('all-time');
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ChessColors.greyG20,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Peshqadamlar",
          style: context.textTheme.bodyMedium.copyWith(
            color: ChessColors.greyG900,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: GestureDetector(
            onTap: context.router.pop,
            child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
              height: 24,
              width: 24,
            ),
          ),
        ),
      ),
      backgroundColor: ChessColors.greyG20,
      body: Column(
        children: [
          // Using ButtonsTabBar for a button-style tabbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: ChessRadius.radiusSm,
                  color: ChessColors.white,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: SizedBox(
                    child: ButtonsTabBar(
                      controller: _tabController,
                      backgroundColor: ChessColors.primaryDefault,
                      unselectedBackgroundColor: ChessColors.white,
                      unselectedLabelStyle:
                          const TextStyle(color: ChessColors.greyG900),
                      labelStyle: context.textTheme.headlineSemibold.copyWith(
                        color: Colors.white,
                      ),

                      borderWidth: 0,
                      radius: 8,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 28,
                      ), // Adding padding between tabs

                      tabs: const [
                        Tab(
                          text: "Haftalik",
                        ),
                        Tab(
                          text: "Oylik",
                        ),
                        Tab(
                          text: "Butun Davr",
                        ),
                      ],
                    ),
                  ),
                )),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboard(), // Weekly leaderboard
                _buildLeaderboard(), // Monthly leaderboard
                _buildLeaderboard(), // All-time leaderboard
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return BlocBuilder<LeaderBoardCubit, LeaderboardState>(
      builder: (context, state) {
        return switch (state) {
          LeaderboardInitState() => const Center(
              child: ChessCircularProgressIndicator(),
            ),
          LeaderboardLoadedState() => Builder(builder: (context) {
              final itemCount = state.leaderboardData.length;
              final isUserUnderTheList = state.currentUser.position > itemCount;

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8),
                itemCount: isUserUnderTheList ? itemCount + 1 : itemCount,
                itemBuilder: (context, position) {
                  if (position == itemCount) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _ThreeDots(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 6,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: state.currentUser.isCurrentUser == true
                                  ? ChessColors.primaryBg
                                  : ChessColors.white,
                              borderRadius: ChessRadius.radiusMd,
                            ),
                            child: _LeaderboardCard(
                              leaderboardData: state.currentUser,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 6,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: state.leaderboardData[position].isCurrentUser ==
                                true
                            ? ChessColors.primaryBg
                            : ChessColors.white,
                        borderRadius: ChessRadius.radiusMd,
                      ),
                      child: _LeaderboardCard(
                        leaderboardData: state.leaderboardData[position],
                      ),
                    ),
                  );
                },
              );
            }),
          LeaderboardErrorState() => const SizedBox.expand(),
        };
      },
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardData leaderboardData;

  const _LeaderboardCard({
    required this.leaderboardData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _IndexIcon(leaderboardData: leaderboardData),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: ChessColors.greyG20,
            ),
            child: ClipOval(
              child: leaderboardData.image != null
                  ? BlocBuilder<AppBaseUrlCubit, AppBaseUrlState>(
                      builder: (context, baseUrlState) {
                        return ChessNetworkImage(
                          imageUrl: leaderboardData.image.toString(),
                          fit: BoxFit.cover,
                          baseUrl: baseUrlState.baseUrl,
                        );
                      },
                    )
                  : ChessUiKitAssets.icons.profile.user.svg(
                      fit: BoxFit.none,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "${leaderboardData.firstName} ${leaderboardData.lastName}",
              style: context.textTheme.headlineSemibold.copyWith(
                color: leaderboardData.isCurrentUser == true
                    ? ChessColors.primaryDefault
                    : ChessColors.greyG900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ChessUiKitAssets.icons.general.queenIcon.svg(
            height: 15,
            width: 16,
          ),
          const SizedBox(width: 4),
          Text(
            leaderboardData.points.toString(),
            style: context.textTheme.subheadlineSemibold.copyWith(
              color: leaderboardData.isCurrentUser == true
                  ? ChessColors.primaryDefault
                  : ChessColors.greyG900,
            ),
          ),
        ],
      ),
    );
  }
}

class _IndexIcon extends StatelessWidget {
  final LeaderboardData leaderboardData;

  const _IndexIcon({
    required this.leaderboardData,
  });

  @override
  Widget build(BuildContext context) {
    switch (leaderboardData.position) {
      case 1:
        return ChessUiKitAssets.images.goldMedal.svg();
      case 2:
        return ChessUiKitAssets.images.silverMedal.svg();
      case 3:
        return ChessUiKitAssets.images.bronzeMedal.svg();
      default:
        return Container(
          decoration: BoxDecoration(
            color: ChessColors.black,
            shape: BoxShape.circle,
            border: Border.all(
              color: leaderboardData.isCurrentUser
                  ? ChessColors.primaryBgStrong
                  : ChessColors.greyG40,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: leaderboardData.isCurrentUser
                ? ChessColors.primaryBg
                : ChessColors.white,
            radius: 11,
            child: Text(
              leaderboardData.position.toString(),
              style: context.textTheme.caption1Medium.copyWith(
                color: leaderboardData.isCurrentUser
                    ? ChessColors.primaryDefault
                    : ChessColors.greyG100,
              ),
            ),
          ),
        );
    }
  }
}

class _ThreeDots extends StatelessWidget {
  const _ThreeDots();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(
        top: 16,
        bottom: 16,
        left: 48,
      ),
      child: Column(
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: ChessColors.greyG200,
          ),
          SizedBox(height: 4),
          Icon(
            Icons.circle,
            size: 10,
            color: ChessColors.greyG200,
          ),
          SizedBox(height: 4),
          Icon(
            Icons.circle,
            size: 10,
            color: ChessColors.greyG200,
          ),
        ],
      ),
    );
  }
}
