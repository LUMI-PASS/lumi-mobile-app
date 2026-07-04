import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_state.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/profile/cubit/profile_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/profile_detail/cubit/profile_detail_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/profile_detail/cubit/profile_detail_state.dart';

/// Compact "Account information" sheet — only first name + last name are
/// editable; phone is shown read-only. Everything else (city/district/etc)
/// is intentionally omitted.
class ProfileDetailBottomsheet extends StatefulWidget {
  const ProfileDetailBottomsheet({super.key});

  static Future<void> show(BuildContext context) async {
    final detailCubit = getIt<ProfileDetailCubit>();
    final profileCubit = context.read<ProfileCubit>();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ProfileDetailCubit>.value(value: detailCubit),
          BlocProvider<ProfileCubit>.value(value: profileCubit),
        ],
        child: const ProfileDetailBottomsheet(),
      ),
    );
  }

  @override
  State<ProfileDetailBottomsheet> createState() =>
      _ProfileDetailBottomsheetState();
}

class _ProfileDetailBottomsheetState extends State<ProfileDetailBottomsheet> {
  final _firstNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileDetailCubit>().getProfileDetail();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _hydrate(HomForUser? user) {
    if (_hydrated || user == null) return;
    _firstNameController.text = user.firstName ?? '';
    _phoneController.text = (user.phoneNumber ?? '').replaceAll('+998', '');
    _hydrated = true;
  }

  void _showDeleteConfirmation(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteConfirmationSheet(
        onConfirm: profileCubit.deleteAccount,
      ),
    );
  }

  void _save(BuildContext context, HomForUser? current) {
    if (current == null) return;
    context.read<ProfileDetailCubit>().updateProfile(
          HomForUser(
            id: current.id,
            firstName: _firstNameController.text.trim(),
            lastName: current.lastName,
            phoneNumber: current.phoneNumber,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<ProfileDetailCubit,
        BaseState<ProfileDetailBuildable, ProfileDetailListenable>>(
      listenWhen: (a, b) =>
          a.listenable?.effect != b.listenable?.effect &&
          b.listenable?.effect == ProfileDetailEffect.verify,
      listener: (_, __) => Navigator.of(context).pop(true),
      buildWhen: (a, b) => a.buildable != b.buildable,
      builder: (_, state) {
        final loading = state.buildable?.isLoading ?? false;
        final saving = state.buildable?.success ?? false;
        final user = state.buildable?.homeModel;
        if (!loading) _hydrate(user);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 14.h,
            bottom: 16.h + viewInsets,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                16.kh,
                Center(
                  child: 'Account information'.s(16).w(700),
                ),
                20.kh,
                if (loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  'First name'.s(13).w(600),
                  8.kh,
                  CommonTextField(
                    controller: _firstNameController,
                    background: context.colors.onPrimary,
                    hint: 'Enter first name',
                  ),
                  12.kh,
                  'Phone number'.s(13).w(600),
                  8.kh,
                  CommonTextField(
                    controller: _phoneController,
                    background: context.colors.onPrimary,
                    hint: '12-345-67-89',
                    prefixIcon: '+998 |'.s(15).w(600),
                    mask: '##-###-##-##',
                    enabled: false,
                  ),
                  24.kh,
                  Row(
                    children: [
                      Expanded(
                        child: CommonButton.outlined(
                          onPressed: saving
                              ? null
                              : () => Navigator.of(context).pop(),
                          text: 'Cancel',
                          textColor: Colors.red,
                          borderColor: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      16.kw,
                      Expanded(
                        child: CommonButton.elevated(
                          loading: saving,
                          onPressed:
                              saving ? null : () => _save(context, user),
                          text: 'Save',
                        ),
                      ),
                    ],
                  ),
                  16.kh,
                  GestureDetector(
                    onTap: saving
                        ? null
                        : () => _showDeleteConfirmation(context),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_forever_rounded,
                              size: 18.w, color: Colors.red.shade400),
                          8.kw,
                          Text(
                            'delete_account'.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DeleteConfirmationSheet extends StatefulWidget {
  const _DeleteConfirmationSheet({required this.onConfirm});
  final Future<void> Function() onConfirm;

  @override
  State<_DeleteConfirmationSheet> createState() =>
      _DeleteConfirmationSheetState();
}

class _DeleteConfirmationSheetState extends State<_DeleteConfirmationSheet> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        16.h,
        24.w,
        16.h + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          24.kh,
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete_forever_rounded,
                size: 36.w, color: Colors.red.shade400),
          ),
          16.kh,
          Text(
            'delete_account'.tr(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          8.kh,
          Text(
            'delete_account_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
          ),
          24.kh,
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _loading ? null : () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        'cancel'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              12.kw,
              Expanded(
                child: GestureDetector(
                  onTap: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          await widget.onConfirm();
                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: _loading
                          ? Colors.red.shade200
                          : Colors.red.shade500,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: _loading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'delete_account'.tr(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
