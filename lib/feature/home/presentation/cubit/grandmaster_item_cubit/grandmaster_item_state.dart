import 'package:founders_academy/feature/home/data/model/grandmaster/grandmaster_data.dart';

sealed class GrandmasterItemState {
  const GrandmasterItemState();
}

class GrandmasterItemLoadingState extends GrandmasterItemState {
  const GrandmasterItemLoadingState();
}

class GrandmasterItemLoadedState extends GrandmasterItemState {
  final GrandmasterData grandmasterData;
  const GrandmasterItemLoadedState(this.grandmasterData);
}

class GrandmasterItemErrorState extends GrandmasterItemState {
  const GrandmasterItemErrorState();
}
