import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_state.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_state.dart';

/// Single bottom sheet for both adding and editing a child.
/// Only first name + age are exposed; other fields are derived/defaulted.
class ChildBottomsheet extends StatefulWidget {
  const ChildBottomsheet({super.key, this.childModel});

  final ChildModel? childModel;

  static Future<void> show(BuildContext context,
      {ChildModel? childModel}) async {
    final cubit = context.read<ChildrenCubit>();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider<ChildrenCubit>.value(
        value: cubit,
        child: ChildBottomsheet(childModel: childModel),
      ),
    );
    // Always refresh — the modal can close after a successful create or by
    // user dismiss; cheap re-fetch is simpler than threading a result back.
    await cubit.getChildren();
  }

  @override
  State<ChildBottomsheet> createState() => _ChildBottomsheetState();
}

class _ChildBottomsheetState extends State<ChildBottomsheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _ageController = TextEditingController();

  bool get _isEdit => widget.childModel != null;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.childModel?.firstName ?? '';
    final age = _computeAge(widget.childModel?.dob);
    if (age != null) _ageController.text = age.toString();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  int? _computeAge(String? dobIso) {
    if (dobIso == null || dobIso.isEmpty) return null;
    try {
      final d = DateTime.parse(dobIso);
      final now = DateTime.now();
      int age = now.year - d.year;
      if (now.month < d.month || (now.month == d.month && now.day < d.day)) {
        age -= 1;
      }
      return age < 0 ? null : age;
    } catch (_) {
      return null;
    }
  }

  String _dobForAge(int age) {
    final now = DateTime.now();
    final t = DateTime(now.year - age, now.month, now.day);
    return '${t.year.toString().padLeft(4, '0')}-'
        '${t.month.toString().padLeft(2, '0')}-'
        '${t.day.toString().padLeft(2, '0')}';
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

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final age = int.parse(_ageController.text.trim());
    final firstName = _firstNameController.text.trim();
    final dob = _dobForAge(age);

    if (_isEdit) {
      final updated = widget.childModel!.copyWith(
        firstName: firstName,
        dob: dob,
      );
      context.read<ChildrenCubit>().submit(updated, true);
    } else {
      final payload = ChildModel(firstName: firstName, dob: dob);
      context.read<ChildrenCubit>().submit(payload, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<ChildrenCubit,
        BaseState<ChildrenBuildable, ChildrenListenable>>(
      listenWhen: (a, b) =>
          a.listenable?.effect != b.listenable?.effect &&
          b.listenable?.effect == ChildrenEffect.verify,
      listener: (_, __) => Navigator.of(context).pop(),
      buildWhen: (a, b) => a.buildable != b.buildable,
      builder: (_, state) {
        final loading = state.buildable?.buttonLoading ?? false;
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 12.h,
            bottom: 16.h + viewInsets,
          ),
          child: SafeArea(
            top: false,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: colors.controlBorder,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  20.kh,
                  Center(
                    child: Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary.withOpacity(0.10),
                      ),
                      child: Icon(
                        Icons.child_care_rounded,
                        size: 36.w,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  16.kh,
                  Center(
                    child: Text(
                      _isEdit ? 'update_child'.tr() : 'add_child'.tr(),
                      style: AppText.semibold16.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  24.kh,
                  _FieldLabel('first_name'.tr()),
                  8.kh,
                  CommonTextField(
                    controller: _firstNameController,
                    hint: 'enter_first_name'.tr(),
                    needToCapitalize: true,
                    background: colors.surface,
                    enabledBorderColor: colors.controlBorder,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 18.h,
                    ),
                    validator: (v) => _validateName(v as String?),
                  ),
                  16.kh,
                  _FieldLabel('age'.tr()),
                  8.kh,
                  CommonTextField(
                    controller: _ageController,
                    hint: 'enter_age'.tr(),
                    background: colors.surface,
                    enabledBorderColor: colors.controlBorder,
                    keyboardType: TextInputType.number,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 18.h,
                    ),
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    validator: (v) => _validateAge(v as String?),
                  ),
                  24.kh,
                  Row(
                    children: [
                      Expanded(
                        child: CommonButton.outlined(
                          onPressed:
                              loading ? null : () => Navigator.of(context).pop(),
                          text: 'cancel'.tr(),
                          textColor: colors.error,
                          backgroundColor: colors.surface,
                          borderColor: colors.error.withOpacity(0.30),
                        ),
                      ),
                      16.kw,
                      Expanded(
                        child: CommonButton.elevated(
                          loading: loading,
                          onPressed: loading ? null : () => _submit(context),
                          text: 'save'.tr(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppText.medium13.copyWith(color: context.colors.textSecondary),
    );
  }
}
