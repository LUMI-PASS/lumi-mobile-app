import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/home/domain/repository/base_home_repository.dart';
import 'package:founders_academy/feature/home/presentation/cubit/afisha_register_cubit/afisha_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class AfishaRegistrationCubit extends ChessCubit<AfishaRegistrationState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  AfishaRegistrationCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(AfishaRegistrationInitial());

  Future<void> register({
    required String id,
    required String dob,
    required String level,
  }) async {
    emit(AfishaRegistrationLoading());
    try {
      await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.registerForTournament(
          id: id,
          body: {
            'dob': dob,
            'level': level,
          },
        ),
      );
      emit(AfishaRegistrationSuccess());
    } on ChessException catch (exception) {
      emit(AfishaRegistrationError(exception.toString()));
      throw UnknownChessException(exception.toString());
    }
  }
}
