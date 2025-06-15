import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'version_state.dart';

@Injectable()
class VersionCubit extends ChessCubit<VersionState> {
  VersionCubit() : super(const VersionInitState());

  void init() {
    _getAppVersion();
  }

  void _getAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      String version;

      if (kDebugMode) {
        version = "${info.version}+${info.buildNumber}";
      } else {
        version = info.version;
      }

      safeEmit(VersionLoadedState(version));
    } on ChessException catch (exception) {
      safeEmit(VersionErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }
}
