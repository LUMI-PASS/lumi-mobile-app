import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/api_model/booking/booking_model.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'wallet_state.dart';

@injectable
class WalletCubit extends BaseCubit<WalletBuildable, WalletListenable> {
  WalletCubit(this._repo) : super(const WalletBuildable());
  final HomeRepository _repo;

  Future<void> getWallet() async {
    build((buildable) => buildable.copyWith(isLoading: true));
    await Future.wait([
      _fetchTariffs(),
      _fetchBalance(),
      _fetchCoinHistory(),
    ]);
    build((buildable) => buildable.copyWith(isLoading: false));
  }

  Future<void> _fetchTariffs() async {
    try {
      final tariffs = await _repo.getTariffs();
      build((buildable) => buildable.copyWith(tariffs: tariffs));
    } on DioException catch (error) {
      if (error.response?.statusCode == 500 ||
          error.response?.statusCode == 502) {
        display.error(Strings.serverErrorTryLater);
      } else if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        display.error(Strings.connectionError);
      }
      display.error(error);
    }
  }

  Future<void> _fetchBalance() async {
    try {
      final balance = await _repo.getUserBalance();
      build((buildable) => buildable.copyWith(balance: balance));
    } catch (_) {}
  }

  Future<void> _fetchCoinHistory() async {
    try {
      final history = await _repo.getCoinHistory();
      build((buildable) => buildable.copyWith(coinHistory: history));
    } catch (_) {}
  }

  Future<void> purchaseSubscription(String tariffId) async {
    return callable(
      future: _repo.purchaseSubscriptionWithResponse(tariffId),
      buildOnStart: () => buildable.copyWith(isSelected: true),
      onErrorData: (error) {
        if (error is DioException) {
          if (error.response?.statusCode == 500 ||
              error.response?.statusCode == 502) {
            display.error(Strings.serverErrorTryLater);
          } else if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.connectionTimeout) {
            display.error(Strings.connectionError);
          } else {
            display.error(error);
          }
        }
      },
      invokeOnData: (PurchaseResponse data) {
        // Open Payme checkout URL in browser
        final url = data.transaction?.checkoutUrl;
        if (url != null && url.isNotEmpty) {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
        return const WalletListenable(effect: WalletEffect.verify);
      },
      buildOnDone: () => buildable.copyWith(isSelected: false),
    );
  }

  void changePhoneState(bool isMatched) {
    build((buildable) => buildable.copyWith(isSelected: isMatched));
  }
}
