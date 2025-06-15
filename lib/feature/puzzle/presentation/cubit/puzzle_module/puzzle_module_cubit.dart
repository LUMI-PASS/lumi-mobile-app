import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle_module/puzzle_module_data.dart';
import 'package:founders_academy/feature/puzzle/domain/repository/base_puzzle_repository.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'puzzle_module_cubit.freezed.dart';
part 'puzzle_module_state.dart';

@Injectable()
class PuzzleModuleCubit extends ChessCubit<PuzzleModuleState> {
  final BasePuzzleRepository _puzzleRepository;

  PuzzleModuleCubit(this._puzzleRepository)
      : super(const PuzzleModuleState.initial());

  void init() {
    _fetchModules();
  }

  void _fetchModules() async {
    safeEmit(const PuzzleModuleState.loading());

    try {
      final modules = await _puzzleRepository.getPuzzleModules();
      safeEmit(PuzzleModuleState.loaded(puzzleModules: modules ?? []));
    } on ChessException catch (exception) {
      safeEmit(PuzzleModuleState.failed(exception));
      throw UnknownChessException(exception.toString());
    }
  }
}
