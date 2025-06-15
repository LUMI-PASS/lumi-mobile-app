part of 'grandmaster_cubit.dart';

sealed class GrandmasterState {
  const GrandmasterState();
}

class GrandmasterLoadingState extends GrandmasterState {
  const GrandmasterLoadingState();
}

class GrandmasterLoadedState extends GrandmasterState {
  final List<GrandmasterData> grandmasterList;
  final int page;
  final bool isNextPageLoading;
  final bool isNextPageAvailable;

  GrandmasterLoadedState({
    required this.grandmasterList,
    required this.page,
    this.isNextPageLoading = false,
    this.isNextPageAvailable = true,
  });

  GrandmasterLoadedState copyWith({
    List<GrandmasterData>? grandmasterList,
    int? page,
    bool? isNextPageLoading,
    bool? isNextPageAvailable,
  }) {
    return GrandmasterLoadedState(
      grandmasterList: grandmasterList ?? this.grandmasterList,
      page: page ?? this.page,
      isNextPageLoading: isNextPageLoading ?? this.isNextPageLoading,
      isNextPageAvailable: isNextPageAvailable ?? this.isNextPageAvailable,
    );
  }
}

class GrandmasterErrorState extends GrandmasterState {
  const GrandmasterErrorState();
}
