import 'package:founders_academy/feature/home/data/model/afisha/afisha_data.dart';

sealed class AfishaState {
  const AfishaState();
}

class AfishaListLoadingState extends AfishaState {
  const AfishaListLoadingState();
}

class AfishaListLoadedState extends AfishaState {
  final List<AfishaData> afishaList;
  final int page;
  final bool isNextPageLoading;
  final bool isNextPageAvailable;

  const AfishaListLoadedState({
    required this.afishaList,
    required this.page,
    this.isNextPageLoading = false,
    this.isNextPageAvailable = true,
  });

  AfishaListLoadedState copyWith({
    List<AfishaData>? afishaList,
    int? page,
    bool? isNextPageLoading,
    bool? isNextPageAvailable,
  }) {
    return AfishaListLoadedState(
      afishaList: afishaList ?? this.afishaList,
      page: page ?? this.page,
      isNextPageLoading: isNextPageLoading ?? this.isNextPageLoading,
      isNextPageAvailable: isNextPageAvailable ?? this.isNextPageAvailable,
    );
  }
}

class AfishaListErrorState extends AfishaState {
  const AfishaListErrorState();
}
