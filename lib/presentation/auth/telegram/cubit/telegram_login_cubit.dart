import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:lumi_pass/presentation/auth/sign_in_session.dart';
import 'package:url_launcher/url_launcher.dart';

import 'telegram_login_state.dart';

@injectable
class TelegramLoginCubit
    extends BaseCubit<TelegramLoginBuildable, TelegramLoginListenable> {
  TelegramLoginCubit(this._repo, this._storage)
      : super(const TelegramLoginBuildable());

  final AuthRepository _repo;
  final Storage _storage;

  TelegramLoginInfo? _info;

  /// Ask the server which bot to open, then open it. Two steps rather than a
  /// hardcoded link so the test bot can be swapped for the real one without an
  /// app release.
  Future<void> start() => callable(
        future: _repo.telegramLoginLink(),
        buildOnStart: () =>
            buildable.copyWith(openingBot: true, error: null),
        onData: (info) async {
          _info = info;
          await _open(info);
        },
        buildOnData: (info) => buildable.copyWith(codeLength: info.codeLength),
        onErrorData: (error) => display.error(error),
        buildOnError: (_) =>
            buildable.copyWith(error: Strings.telegramLoginUnavailable),
        buildOnDone: () => buildable.copyWith(openingBot: false),
      );

  /// The "open the bot again" affordance, for a user who came back to the app
  /// before the bot had answered, or whose first launch failed.
  Future<void> reopenBot() async {
    final info = _info;
    if (info == null) return start();
    await _open(info);
  }

  Future<void> _open(TelegramLoginInfo info) async {
    // An https://t.me link, deliberately: it hands off to the Telegram app when
    // it is installed and falls back to the web page when it is not, so a user
    // without Telegram sees something useful instead of a dead tap.
    final uri = Uri.tryParse(info.url);
    if (uri == null) {
      build((b) => b.copyWith(error: Strings.telegramLoginUnavailable));
      return;
    }
    try {
      final opened =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        build((b) => b.copyWith(error: Strings.telegramOpenFailed));
      }
    } catch (e, s) {
      log.e(e.toString(), error: e, stackTrace: s);
      build((b) => b.copyWith(error: Strings.telegramOpenFailed));
    }
  }

  /// Called on every keystroke: keeps the Confirm button in step with the
  /// field, and clears a previous "wrong code" as soon as the user edits.
  void changeCode(String code) {
    build((b) => b.copyWith(code: code, error: null));
  }

  /// [code] stays a String the whole way down. Parsing it to an int would drop
  /// a leading zero and turn a valid code into one that can never match.
  Future<void> submit(String code) => callable(
        future: _repo.telegramLogin(code),
        buildOnStart: () => buildable.copyWith(loading: true, error: null),
        onData: (result) async {
          await applySignedInSession(
            storage: _storage,
            result: result,
            // The user never typed a phone number; the server resolved it from
            // the code and sent it back on the profile.
            phone: result.user?.phoneNumber ?? '',
          );
          invoke(const TelegramLoginListenable(TelegramLoginEffect.success));
        },
        onErrorData: (error) => display.error(error),
        buildOnError: (_) => buildable.copyWith(error: Strings.invalidCode),
        buildOnDone: () => buildable.copyWith(loading: false),
      );
}
