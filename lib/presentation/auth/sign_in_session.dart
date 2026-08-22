import 'package:lumi_pass/common/utils/avatar_notifier.dart';
import 'package:lumi_pass/common/utils/display_name_notifier.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';

/// Hands this device over to whoever just signed in.
///
/// Shared by every way in — the SMS code and the Telegram bot — because all of
/// it is about the *previous* occupant of the device, and none of it is about
/// how the current one proved who they are. A second sign-in path that
/// reimplemented this would drift, and the drift would look like the last
/// user's name on Home or a new account that never sees onboarding.
Future<void> applySignedInSession({
  required Storage storage,
  required VerifyOtpResult result,
  required String phone,
}) async {
  // Signing in is the authoritative sync point for who this device belongs to.
  // The server's answer wins outright — including when the answer is "this
  // account has no name yet". Only *setting* a name here left the previous
  // account's name in the box for anyone who signs in without having explicitly
  // logged out first, and Home then greeted the new user by the old user's name.
  final name = result.user?.firstName;
  if (name != null && name.isNotEmpty) {
    await storage.parentName.set(name);
    displayNameNotifier.value = name;
  } else {
    await storage.parentName.set(null);
    displayNameNotifier.value = null;
  }

  if (result.isNewUser) {
    // Nothing on this device belongs to a brand-new account — drop the last
    // user's child and avatar, and let the profile prompt come back.
    await storage.childName.set(null);
    await storage.childAge.set(null);
    await storage.avatarPath.set(null);
    await storage.profilePromptDismissed.set(null);
    parentAvatarNotifier.value = null;

    await storage.needsOnboarding.set(true);
    if (phone.isNotEmpty) await storage.pendingPhone.set(phone);
  } else {
    await storage.needsOnboarding.set(false);
  }

  // Pull this account's plan now. AppCubit lives for the whole run and synced
  // at cold start — when that happened before sign-in it found no session, so
  // without this the buyer's coupon prices wouldn't appear until the next launch.
  await getIt<AppCubit>().onSignedIn();
}
