import 'package:lumi_pass/feature/home/data/model/afisha/afisha_data.dart';

sealed class AfishaItemState {
  const AfishaItemState();
}

class AfishaItemLoadingState extends AfishaItemState {
  const AfishaItemLoadingState();
}

class AfishaItemLoadedState extends AfishaItemState {
  final AfishaData afishaData;
  const AfishaItemLoadedState(this.afishaData);
}

class AfishaItemErrorState extends AfishaItemState {
  const AfishaItemErrorState();
}
