import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/router/referral_link.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';
import 'package:lumi_pass/data/service/referral/referral_coordinator.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/referrals/referral_repository.dart';

/// Looks a typed code up (debounced) so a field can say "Invited by Aziza"
/// before anything is submitted. Purely informational: an unknown code only
/// earns a soft hint — the apply call is what decides.
///
/// `GET /referrals/lookup/:code` requires a session: without one it answers
/// 401, which the app's AuthInterceptor treats as an expired login and signs
/// the user out. So nothing is looked up unless [_isSignedIn] — both screens
/// that use this are reached only after sign-in anyway.
class ReferralCodeLookup extends ChangeNotifier {
  ReferralCodeLookup({ReferralRepository? repo, bool Function()? isSignedIn})
      : _repo = repo ?? getIt<ReferralRepository>(),
        _isSignedIn =
            isSignedIn ?? (() => getIt<ReferralCoordinator>().isSignedIn);

  final ReferralRepository _repo;
  final bool Function() _isSignedIn;
  Timer? _debounce;
  String? _code;
  bool _disposed = false;

  /// The answer for the code currently in the field; null while unknown.
  ReferralLookup? result;

  void onChanged(String text) {
    final code = ReferralCodes.normalize(text);
    if (code == _code) return;
    _code = code;
    _debounce?.cancel();
    if (result != null) {
      result = null;
      notifyListeners();
    }
    if (code == null || !_isSignedIn()) return;
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      final answer = await _repo.lookup(code);
      if (_disposed || _code != code) return;
      result = answer;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}

/// The line under a code field: "Invited by Aziza" when the code is real, a
/// soft "check the code" when the server does not know it, nothing otherwise.
class ReferralLookupHint extends StatelessWidget {
  const ReferralLookupHint({super.key, required this.lookup});

  final ReferralCodeLookup lookup;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: lookup,
      builder: (context, _) {
        final r = lookup.result;
        if (r == null) return const SizedBox.shrink();
        final name = r.referrerFirstName;
        final text = !r.valid
            ? 'referral_code_unknown_hint'.tr()
            : (name == null
                ? 'referral_code_valid'.tr()
                : 'referral_invited_by'.tr(args: [name]));
        return Padding(
          padding: EdgeInsets.only(top: 6.h, left: 8.w),
          child: Text(
            text,
            style: AppText.regular12.copyWith(
              color: r.valid ? AppColors.tagGreen : context.colors.textMuted,
            ),
          ),
        );
      },
    );
  }
}

/// Uppercases as the user types, so the field shows the code the way it will
/// be sent and the way it is printed everywhere else.
class UpperCaseCodeFormatter extends TextInputFormatter {
  const UpperCaseCodeFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
