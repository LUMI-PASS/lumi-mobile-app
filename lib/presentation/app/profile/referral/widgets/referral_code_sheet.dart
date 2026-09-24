import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/display/display.dart';
import 'package:lumi_pass/common/widget/pill_card.dart';
import 'package:lumi_pass/data/service/referral/pending_referral.dart';
import 'package:lumi_pass/data/service/referral/referral_coordinator.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/profile/referral/referral_actions.dart';
import 'package:lumi_pass/presentation/app/profile/referral/widgets/referral_code_lookup.dart';

/// "Have a referral code?" — type someone's code and apply it.
///
/// Resolves to true when the code was applied, so the caller can refresh.
/// A refusal stays in the sheet, under the field, localised from its
/// `error_code`; success closes the sheet with an "Invited by X" toast.
Future<bool> showReferralCodeSheet(BuildContext context) async {
  final applied = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ReferralCodeSheet(),
  );
  return applied ?? false;
}

class _ReferralCodeSheet extends StatefulWidget {
  const _ReferralCodeSheet();

  @override
  State<_ReferralCodeSheet> createState() => _ReferralCodeSheetState();
}

class _ReferralCodeSheetState extends State<_ReferralCodeSheet> {
  final _coordinator = getIt<ReferralCoordinator>();
  late final TextEditingController _ctrl;
  final _lookup = ReferralCodeLookup();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // An invite link that has not been applied yet is the likeliest thing
    // this person came here to enter.
    _ctrl = TextEditingController(text: _coordinator.pending?.code ?? '');
    _lookup.onChanged(_ctrl.text);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _lookup.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final choice = PendingReferralPolicy.choose(
      typed: _ctrl.text,
      pending: _coordinator.pending,
    );
    if (choice == null || _loading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    // Typed on purpose in a sheet that exists for it — a refusal is shown
    // whatever the code's origin.
    final outcome =
        await _coordinator.applyFromForm(choice.code, source: choice.source);
    if (!mounted) return;
    if (outcome.isSuccess) {
      getIt<Display>()
          .success(referralInvitedByMessage(outcome.result?.referrerName));
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _loading = false;
      _error = referralErrorMessage(outcome.error);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        16.h,
        24.w,
        16.h + (bottom > 0 ? bottom : MediaQuery.of(context).padding.bottom),
      ),
      decoration: BoxDecoration(
        color: c.scaffoldBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: c.control,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          24.kh,
          Text(
            'referral_have_code'.tr(),
            textAlign: TextAlign.center,
            style: AppText.heading20.copyWith(color: c.textPrimary),
          ),
          8.kh,
          Text(
            'referral_have_code_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: AppText.regular14.copyWith(color: c.textSecondary),
          ),
          20.kh,
          PillCard(
            leading: PillIconBadge(
              child: Assets.icons.detail.icDiscount.svg(width: 20.w),
            ),
            child: TextField(
              controller: _ctrl,
              enabled: !_loading,
              autofocus: _ctrl.text.isEmpty,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: const [UpperCaseCodeFormatter()],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _apply(),
              onChanged: (v) {
                _lookup.onChanged(v);
                if (_error != null) setState(() => _error = null);
              },
              cursorColor: AppColors.link,
              style: AppText.semibold14.copyWith(color: c.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: 'referral_code_hint'.tr(),
                hintStyle:
                    AppText.semibold14.copyWith(color: c.textSecondary),
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h, left: 8.w),
              child: Text(
                _error!,
                style: AppText.regular12.copyWith(color: AppColors.error),
              ),
            )
          else
            ReferralLookupHint(lookup: _lookup),
          20.kh,
          GradientButton(
            text: 'referral_apply'.tr(),
            loading: _loading,
            onPressed: _apply,
          ),
        ],
      ),
    );
  }
}
