import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'wallet_state.dart';
import 'package:location/location.dart';

@injectable
class WalletCubit extends BaseCubit<WalletBuildable, WalletListenable> {
  WalletCubit(this._repo) : super(const WalletBuildable());
  final HomeRepository _repo;

  Future<void> getWallet() async {
    return callable(
      future: _repo.getTariffs(),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      buildOnData: (data) {
        return buildable.copyWith(tariffs: data);
      },
      onErrorData: (error) {
        final status = (error as DioException);
        if (status.response?.statusCode == 500 ||
            status.response?.statusCode == 502) {
          display.error(Strings.serverErrorTryLater);
        } else if (status.type == DioExceptionType.connectionError ||
            status.type == DioExceptionType.connectionTimeout) {
          display.error(Strings.connectionError);
        }
        display.error(error);
      },
      buildOnDone: () => buildable.copyWith(isLoading: false),
    );
  }

  void changePhoneState(bool isMatched) {
    build((buildable) => buildable.copyWith(isSelected: isMatched));
  }
}
