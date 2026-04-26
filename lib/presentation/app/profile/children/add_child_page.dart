import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';

import 'cubit/children_cubit.dart';
import 'cubit/children_state.dart';

@RoutePage()
class AddChildPage
    extends BasePage<ChildrenCubit, ChildrenBuildable, ChildrenListenable> {
  final ChildModel? childModel;
  final String? parentId;

  AddChildPage({super.key, required this.childModel, required this.parentId});

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isEdit => childModel != null;

  @override
  void init(BuildContext context) {
    _firstNameController.text = childModel?.firstName ?? '';
    final initialAge = _computeAge(childModel?.dob);
    if (initialAge != null) {
      _ageController.text = initialAge.toString();
    }
    // Reset stepper so the cubit never lands on the legacy photo step.
    context.read<ChildrenCubit>().setStep(0);
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
    final target = DateTime(now.year - age, now.month, now.day);
    return '${target.year.toString().padLeft(4, '0')}-'
        '${target.month.toString().padLeft(2, '0')}-'
        '${target.day.toString().padLeft(2, '0')}';
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

    final payload = ChildModel(
      firstName: firstName,
      lastName: childModel?.lastName ?? '',
      gender: childModel?.gender ?? 'MALE',
      dob: _dobForAge(age),
      city: childModel?.city ?? 'Tashkent',
      district: childModel?.district ?? 'Tashkent',
    );

    if (_isEdit) {
      final updated = childModel!.copyWith(
        firstName: payload.firstName,
        lastName: payload.lastName,
        gender: payload.gender,
        dob: payload.dob,
        city: payload.city,
        district: payload.district,
      );
      context.read<ChildrenCubit>().submit(updated, true);
    } else {
      context.read<ChildrenCubit>().submit(payload, false);
    }
  }

  @override
  void listener(BuildContext context, ChildrenListenable state) {
    if (state.effect == ChildrenEffect.verify) {
      context.router.pop();
    }
    super.listener(context, state);
  }

  @override
  Widget builder(BuildContext context, ChildrenBuildable state) {
    return Scaffold(
      appBar: BaseAppBar(
        title: _isEdit ? 'update_child'.tr() : 'add_child'.tr(),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colors.primary.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.child_care_rounded,
                            size: 36.w,
                            color: context.colors.primary,
                          ),
                        ),
                        20.kh,
                        'first_name'.tr().s(13).w(600),
                        8.kh,
                        CommonTextField(
                          controller: _firstNameController,
                          hint: 'enter_first_name'.tr(),
                          needToCapitalize: true,
                          background: context.colors.onPrimary,
                          validator: (v) => _validateName(v as String?),
                        ),
                        16.kh,
                        'age'.tr().s(13).w(600),
                        8.kh,
                        CommonTextField(
                          controller: _ageController,
                          hint: 'enter_age'.tr(),
                          background: context.colors.onPrimary,
                          keyboardType: TextInputType.number,
                          inputFormatter: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          validator: (v) => _validateAge(v as String?),
                        ),
                        const Spacer(),
                        20.kh,
                        Row(
                          children: [
                            Expanded(
                              child: CommonButton.outlined(
                                onPressed: state.buttonLoading
                                    ? null
                                    : () => context.router.pop(),
                                text: 'cancel'.tr(),
                                textColor: Colors.red,
                                borderColor: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            16.kw,
                            Expanded(
                              child: CommonButton.elevated(
                                loading: state.buttonLoading,
                                onPressed: state.buttonLoading
                                    ? null
                                    : () => _submit(context),
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
          ),
        ),
      ),
    );
  }
}
