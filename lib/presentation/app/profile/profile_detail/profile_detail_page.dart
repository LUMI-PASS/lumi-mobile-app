import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/common/widget/initials_avatar.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/profile/profile_detail/cubit/profile_detail_cubit.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';

import 'cubit/profile_detail_state.dart';

/// "Мои информации" — the account screen reached from Profile → "Tahrirlash".
///
/// The profile page has already loaded the parent, so [user] is handed over on
/// navigation and the screen never refetches it — it only writes.
///
/// Only the first name is editable; the phone stays read-only. The avatar is a
/// display-only initials circle — there is no photo upload.
///
/// Deleting the account is confirmed here but executed by `ProfileCubit`,
/// which owns the post-delete navigation. So the screen pops with `true` and
/// the profile page fires the delete.
@RoutePage()
class ProfileDetailPage extends BasePage<ProfileDetailCubit,
    ProfileDetailBuildable, ProfileDetailListenable> {
  const ProfileDetailPage({super.key, required this.user});

  final HomForUser user;

  @override
  void listener(BuildContext context, ProfileDetailListenable state) {
    if (state.effect == ProfileDetailEffect.verify) {
      context.router.maybePop();
    }
    super.listener(context, state);
  }

  @override
  Widget builder(BuildContext context, ProfileDetailBuildable state) {
    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: BaseAppBar(title: 'my_info'.tr()),
      body: _AccountForm(user: user, saving: state.success),
    );
  }
}

class _AccountForm extends StatefulWidget {
  const _AccountForm({required this.user, required this.saving});

  final HomForUser user;
  final bool saving;

  @override
  State<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<_AccountForm> {
  late final _firstNameController = TextEditingController(
    text: widget.user.firstName ?? '',
  );
  late final _phoneController = TextEditingController(
    text: (widget.user.phoneNumber ?? '').replaceAll('+998', ''),
  );

  @override
  void dispose() {
    _firstNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<ProfileDetailCubit>().updateProfile(
          HomForUser(
            id: widget.user.id,
            firstName: _firstNameController.text.trim(),
            lastName: widget.user.lastName,
            phoneNumber: widget.user.phoneNumber,
          ),
        );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DeleteAccountSheet(),
    );
    if (confirmed == true && mounted) {
      context.router.maybePop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            child: Column(
              children: [
                InitialsAvatar(name: widget.user.firstName ?? ''),
                20.kh,
                CommonTextField(
                  controller: _firstNameController,
                  background: colors.surface,
                  hint: 'first_name'.tr(),
                  hintColor: AppColors.textMuted,
                  enabledBorderColor: Colors.transparent,
                  disabledBorderColor: Colors.transparent,
                  needToCapitalize: true,
                ),
                12.kh,
                CommonTextField(
                  controller: _phoneController,
                  background: colors.surface,
                  hint: 'phone_number_label'.tr(),
                  hintColor: AppColors.textMuted,
                  enabledBorderColor: Colors.transparent,
                  disabledBorderColor: Colors.transparent,
                  prefixIcon: Text(
                    '+998 |',
                    style:
                        AppText.semibold16.copyWith(color: colors.textPrimary),
                  ),
                  mask: '##-###-##-##',
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
        BottomBox(
          child: Row(
            children: [
              Expanded(
                child: CommonButton.elevated(
                  text: 'delete_account'.tr(),
                  backgroundColor: AppColors.error,
                  textColor: AppColors.onBrand,
                  radius: 44.r,
                  enabled: !widget.saving,
                  onPressed: _confirmDelete,
                ),
              ),
              8.kw,
              Expanded(
                child: GradientButton(
                  text: 'save_button'.tr(),
                  loading: widget.saving,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Confirmation for the destructive action. Pops `true` once the user goes
/// through with it.
class _DeleteAccountSheet extends StatelessWidget {
  const _DeleteAccountSheet();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        16.h,
        24.w,
        16.h + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          24.kh,
          Text(
            'delete_account'.tr(),
            style: AppText.heading20.copyWith(color: colors.textPrimary),
          ),
          8.kh,
          Text(
            'delete_account_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: AppText.regular14.copyWith(color: colors.textSecondary),
          ),
          24.kh,
          Row(
            children: [
              Expanded(
                child: CommonButton.outlined(
                  text: 'cancel'.tr(),
                  textColor: colors.textPrimary,
                  borderColor: colors.border,
                  backgroundColor: colors.surface,
                  radius: 44.r,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              8.kw,
              Expanded(
                child: CommonButton.elevated(
                  text: 'delete_account'.tr(),
                  backgroundColor: AppColors.error,
                  textColor: AppColors.onBrand,
                  radius: 44.r,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
