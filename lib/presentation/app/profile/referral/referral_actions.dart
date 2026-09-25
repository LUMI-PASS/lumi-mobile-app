import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/widget/display/display.dart';
import 'package:lumi_pass/data/api_model/referral/referral_enums.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/referrals/referral_repository.dart';
import 'package:share_plus/share_plus.dart';

/// Copy + toast. Shared by the profile card and the referral screen.
Future<void> copyReferralText(String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  getIt<Display>().success('referral_copied'.tr());
}

/// Opens the share sheet with the server's localised share text, then records
/// a `shared` event — unless the sheet was dismissed without sharing.
Future<void> shareReferral(BuildContext context, ReferralMe me) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null || !box.hasSize
      ? null
      : box.localToGlobal(Offset.zero) & box.size;
  try {
    final result = await Share.share(
      me.shareMessage,
      subject: 'referral_invite_title'.tr(),
      sharePositionOrigin: origin,
    );
    if (result.status == ShareResultStatus.dismissed) return;
    unawaited(getIt<ReferralRepository>().logEvent(
      ReferralEventType.shared,
      // The target app on iOS/Android 5.1+ ("com.whatsapp", …); empty where
      // the platform does not say.
      channel: result.raw.isEmpty ? null : result.raw,
      code: me.code,
    ));
  } catch (_) {
    // No share sheet on this device — nothing useful to tell the user.
  }
}

/// "Get 50% off (up to 200 000 so'm) when a friend makes their first purchase".
String referralRewardLine(ReferralReward reward) => 'referral_reward_line'.tr(
      args: ['${reward.percent}', reward.maxDiscount.toRawUzsPrice()],
    );

/// The localised message for a refused typed code.
String referralErrorMessage(ReferralErrorCode? code) =>
    (code ?? ReferralErrorCode.unknown).messageKey.tr();

/// "Invited by Aziza", or a plain success line when the referrer has no name.
String referralInvitedByMessage(String? name) => name == null || name.isEmpty
    ? 'referral_applied_success'.tr()
    : 'referral_invited_by'.tr(args: [name]);
