import 'package:founders_academy/core/api/environment/environment_manager.dart';
import 'package:founders_academy/feature/base_url/app_base_url_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class AppBaseUrlCubit extends ChessCubit<AppBaseUrlState> {
  final EnvironmentManager _environmentManager;
  AppBaseUrlCubit(this._environmentManager) : super(AppBaseUrlState());

  Future<void> init() async {
    final baseUrl = _environmentManager.baseUrl;
    print("base_url :::::   $baseUrl");
    safeEmit(state.copyWith(baseUrl: baseUrl));
  }
}
