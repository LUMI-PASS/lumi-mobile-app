import 'package:freezed_annotation/freezed_annotation.dart';

part 'telegram_login_state.freezed.dart';

@freezed
class TelegramLoginBuildable with _$TelegramLoginBuildable {
  const factory TelegramLoginBuildable({
    /// Opening the bot chat, before the user has anywhere to type a code.
    @Default(false) bool openingBot,
    @Default(false) bool loading,

    /// Digits the bot's code has. The server owns this number; 6 is only the
    /// value assumed until /telegram/link answers.
    @Default(6) int codeLength,
    @Default(null) String? error,

    /// What is currently in the code field. Held here so the Confirm button
    /// enables as the user types — a TextEditingController read during build
    /// is a snapshot, and nothing rebuilds when it changes.
    @Default('') String code,
  }) = _TelegramLoginBuildable;
}

@freezed
class TelegramLoginListenable with _$TelegramLoginListenable {
  const factory TelegramLoginListenable(TelegramLoginEffect effect) =
      _TelegramLoginListenable;
}

enum TelegramLoginEffect { success }
