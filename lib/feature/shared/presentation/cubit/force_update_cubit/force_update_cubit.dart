import 'package:founders_academy/core/version/version_manager.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/force_update_cubit/force_update_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class ForceUpdateCubit extends ChessCubit<ForceUpdateState> {
  final VersionManager _versionManager;

  ForceUpdateCubit(
    this._versionManager,
  ) : super(const ForceUpdateInitialState());

  Future<void> onUpdateTap() async {
    _versionManager.onUpdateTap();
  }
}
