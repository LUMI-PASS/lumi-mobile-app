import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/child_age.dart';
import 'package:lumi_pass/common/utils/photo_urls.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/avatar_picker.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_state.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';

/// "Детали ребёнка" — name, age and gender for one child, reached from the
/// edit badge on a child in Profile. With [child] null it adds a new one.
///
/// The parent already holds the children, so the child is handed over on
/// navigation and nothing is fetched here — the screen only writes. It pops
/// `true` after a successful save so the profile can refresh.
@RoutePage()
class ChildDetailPage
    extends BasePage<ChildrenCubit, ChildrenBuildable, ChildrenListenable> {
  const ChildDetailPage({super.key, this.child});

  final ChildModel? child;

  @override
  void listener(BuildContext context, ChildrenListenable state) {
    if (state.effect == ChildrenEffect.verify) {
      context.router.maybePop(true);
    }
    super.listener(context, state);
  }

  @override
  Widget builder(BuildContext context, ChildrenBuildable state) {
    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: BaseAppBar(
        title: child == null ? 'add_child'.tr() : 'child_details'.tr(),
        actions: [
          // Nothing to delete until the child exists.
          if (child != null)
            appBarDeleteAction(
              context,
              enabled: !state.buttonLoading,
              onTap: () => _confirmDeleteChild(context, child!),
            ),
        ],
      ),
      body: _ChildForm(child: child, saving: state.buttonLoading),
    );
  }
}

/// Confirms, then removes the child through the cubit — which pops the screen
/// once the delete lands.
Future<void> _confirmDeleteChild(BuildContext context, ChildModel child) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _DeleteChildSheet(name: child.firstName ?? ''),
  );
  if (confirmed == true && context.mounted) {
    context.read<ChildrenCubit>().deleteChild(child.id!);
  }
}

class _ChildForm extends StatefulWidget {
  const _ChildForm({required this.child, required this.saving});

  final ChildModel? child;
  final bool saving;

  @override
  State<_ChildForm> createState() => _ChildFormState();
}

class _ChildFormState extends State<_ChildForm> {
  static const _male = 'MALE';
  static const _female = 'FEMALE';

  final _formKey = GlobalKey<FormState>();

  late final _firstNameController = TextEditingController(
    text: widget.child?.firstName ?? '',
  );
  late final _ageController = TextEditingController(
    text: (widget.child?.age ?? getAge(widget.child?.dob))?.toString() ?? '',
  );
  late String _gender =
      (widget.child?.gender ?? '').toUpperCase() == _female ? _female : _male;

  /// Picked on this screen; uploaded as part of the save.
  File? _photo;

  bool get _isEdit => widget.child != null;

  /// The photo already on the server. The endpoint 404s when the child has
  /// none, so only ask for it when the model says there is one.
  String? get _serverPhotoUrl {
    final child = widget.child;
    if (child?.id == null || child?.hasPhoto != true) return null;
    return childPhotoUrl(child!.id!);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'required'.tr();
    if (v.length > 50) return 'max_50_chars'.tr(args: ['First name']);
    return null;
  }

  String? _validateAge(String? value) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null) return 'required'.tr();
    if (n <= 0 || n > 17) return 'child_max_age'.tr();
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final firstName = _firstNameController.text.trim();
    final dob = dobForAge(int.parse(_ageController.text.trim()));
    final cubit = context.read<ChildrenCubit>();

    final child = _isEdit
        ? widget.child!.copyWith(
            firstName: firstName,
            dob: dob,
            gender: _gender,
          )
        : ChildModel(firstName: firstName, dob: dob, gender: _gender);

    cubit.saveChild(child, _isEdit, _photo);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: AvatarPicker(
                      pickedFile: _photo,
                      imageUrl: _serverPhotoUrl,
                      onPicked: (file) => setState(() => _photo = file),
                    ),
                  ),
                  20.kh,
                  CommonTextField(
                    controller: _firstNameController,
                    background: colors.surface,
                    hint: 'first_name'.tr(),
                    hintColor: AppColors.textMuted,
                    enabledBorderColor: Colors.transparent,
                    needToCapitalize: true,
                    validator: (v) => _validateName(v as String?),
                  ),
                  12.kh,
                  CommonTextField(
                    controller: _ageController,
                    background: colors.surface,
                    hint: 'age'.tr(),
                    hintColor: AppColors.textMuted,
                    enabledBorderColor: Colors.transparent,
                    keyboardType: TextInputType.number,
                    suffixText: 'years_suffix'.tr(),
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    validator: (v) => _validateAge(v as String?),
                  ),
                  12.kh,
                  Row(
                    children: [
                      _GenderChip(
                        label: 'male'.tr(),
                        selected: _gender == _male,
                        onTap: () => setState(() => _gender = _male),
                      ),
                      12.kw,
                      _GenderChip(
                        label: 'female'.tr(),
                        selected: _gender == _female,
                        onTap: () => setState(() => _gender = _female),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          BottomBox(
            child: GradientButton(
              text: 'save_button'.tr(),
              loading: widget.saving,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}

/// Confirmation before removing a child. Pops `true` on confirm.
class _DeleteChildSheet extends StatelessWidget {
  const _DeleteChildSheet({required this.name});

  final String name;

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
            'delete_child'.tr(),
            style: AppText.heading20.copyWith(color: colors.textPrimary),
          ),
          8.kh,
          Text(
            'delete_child_subtitle'.tr(args: [name]),
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
                  text: 'delete'.tr(),
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

/// Pill toggle — brand gradient when picked, plain white card when not.
class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Bouncing(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? null : colors.surface,
          gradient: selected ? AppGradients.brand : null,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Text(
          label,
          style: AppText.semibold12.copyWith(
            color: selected ? AppColors.onBrand : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
