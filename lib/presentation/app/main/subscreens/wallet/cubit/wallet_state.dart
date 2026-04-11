import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/tarifff/tariff_model.dart';

part 'wallet_state.freezed.dart';

@freezed
class WalletBuildable with _$WalletBuildable {
  const factory WalletBuildable(
      {@Default(false) bool isSelected,
      @Default(false) bool isLoading,
      @Default(false) bool success,
      @Default(0) num balance,
      List<Tariff>? tariffs,
      @Default([]) List<CoinFlow> coinHistory}) = _WalletBuildable;
}

@freezed
class WalletListenable with _$WalletListenable {
  const factory WalletListenable({
    required WalletEffect effect,
  }) = _WalletListenable;
}

enum WalletEffect { verify, reg }
