import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChessCubit<State> extends Cubit<State> {
  ChessCubit(super.initialState);

  void safeEmit(State state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
