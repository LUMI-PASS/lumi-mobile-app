import 'package:founders_academy/feature/puzzle/data/model/grandmaster_bot/grandmaster_bot_data.dart';

sealed class GrandMasterBotState {}

final class GrandMasterBotInitial extends GrandMasterBotState {}

final class GrandMasterBotLoadedState extends GrandMasterBotState {
  final List<GrandmasterBotData> grandMasterBotData;
  GrandMasterBotLoadedState(
    this.grandMasterBotData,
  );
}

class GrandMasterBotErrorState extends GrandMasterBotState {
  GrandMasterBotErrorState();
}
