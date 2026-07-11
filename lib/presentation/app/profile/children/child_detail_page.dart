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
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/common/widget/initials_avatar.dart';
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
      ),
      body: _ChildForm(child: child, saving: state.buttonLoading),
    );
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

  bool get _isEdit => widget.child != null;

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

    if (_isEdit) {
      cubit.submit(
        widget.child!.copyWith(
          firstName: firstName,
          dob: dob,
          gender: _gender,
        ),
        true,
      );
    } else {
      cubit.submit(
        ChildModel(firstName: firstName, dob: dob, gender: _gender),
        false,
      );
    }
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
                    child: InitialsAvatar(
                      name: widget.child?.firstName ?? '',
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
