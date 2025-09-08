import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/presentation/app/widgets/base_box.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';

import 'cubit/children_cubit.dart';
import 'cubit/children_state.dart';

@RoutePage()
class AddChildPage
    extends BasePage<ChildrenCubit, ChildrenBuildable, ChildrenListenable> {
  final ChildModel? childModel;
  final String? parentId;

  AddChildPage({super.key, required this.childModel, required this.parentId});

  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void init(context) {
    _initializeControllers(context);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _initializeControllers(BuildContext context) {
    _firstNameController.text = childModel?.firstName ?? '';
    _lastNameController.text = childModel?.lastName ?? '';
    _phoneController.text = childModel?.phoneNumber ?? '';
    _cityController.text = childModel?.city ?? '';
    _districtController.text = childModel?.district ?? '';

    if (childModel?.dob != null && childModel!.dob!.isNotEmpty) {
      try {
        final selectedDate = DateTime.parse(childModel!.dob!);
        context.read<ChildrenCubit>().setBirthDate(selectedDate);
        _dobController.text =
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      } catch (e) {
        context.read<ChildrenCubit>().setBirthDate(null);
        _dobController.text = '';
      }
    }

    // Initialize gender if editing
    if (childModel?.gender != null && childModel!.gender!.isNotEmpty) {
      context.read<ChildrenCubit>().changeGender(childModel!.gender!);
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Calculate age and validate
  String? _validateAge(DateTime? selectedDate) {
    if (selectedDate == null) {
      return 'Date of birth is required';
    }

    final now = DateTime.now();
    final age = now.year - selectedDate.year;
    final hasHadBirthdayThisYear = now.month > selectedDate.month ||
        (now.month == selectedDate.month && now.day >= selectedDate.day);

    final actualAge = hasHadBirthdayThisYear ? age : age - 1;

    if (actualAge > 16) {
      return 'Child must be 16 years old or younger';
    }

    if (actualAge < 0) {
      return 'Invalid birth date';
    }

    return null;
  }

  Future<void> _selectDate(
      BuildContext context, DateTime? currentSelectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentSelectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 8)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != currentSelectedDate) {
      // Update date in bloc
      context.read<ChildrenCubit>().setBirthDate(picked);
      _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  void _handleSubmit(
      BuildContext context, String gender, DateTime? selectedDate) {
    final ageError = _validateAge(selectedDate);
    if (ageError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ageError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    ChildModel childModel2;
    if (childModel == null) {
      childModel2 = ChildModel(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: gender.toUpperCase(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        dob: DateFormat("yyyy-MM-dd").format(selectedDate!),
      );
    } else {
      childModel2 = childModel!.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: gender.toUpperCase(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        dob: DateFormat("yyyy-MM-dd").format(selectedDate!),
      );
    }

    context.read<ChildrenCubit>().submit(childModel2, childModel != null);
  }

  @override
  void listener(BuildContext context, ChildrenListenable state) {
    if (state.effect == ChildrenEffect.verify) {
      context.router.pop();
    }
    super.listener(context, state);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      appBar: BaseAppBar(
        title: childModel != null ? "Update child" : "Add child",
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Name
                    "First Name".s(15).w(600),
                    12.kh,
                    CommonTextField(
                      controller: _firstNameController,
                      hint: "Joseph",
                      disabledBorderColor: context.colors.primary,
                      enabledBorderColor: context.colors.primary,
                      validator: (value) =>
                          _validateRequired(value, 'First name'),
                      prefixIcon: BaseBox(
                        width: 32,
                        height: 32,
                        radius: 10,
                        padding: const EdgeInsets.all(4),
                        backgroundColor: context.colors.primary,
                        child: Assets.icons.profilee.svg(),
                      ),
                    ),
                    16.kh,

                    // Last Name
                    "Last Name".s(15).w(600),
                    12.kh,
                    CommonTextField(
                      controller: _lastNameController,
                      hint: "Ren",
                      disabledBorderColor: context.colors.primary,
                      enabledBorderColor: context.colors.primary,
                      validator: (value) =>
                          _validateRequired(value, 'Last name'),
                      prefixIcon: BaseBox(
                        width: 32,
                        height: 32,
                        radius: 10,
                        padding: const EdgeInsets.all(4),
                        backgroundColor: context.colors.primary,
                        child: Assets.icons.profilee.svg(),
                      ),
                    ),
                    16.kh,

                    // Date of Birth
                    "Date of Birth".s(15).w(600),
                    12.kh,
                    GestureDetector(
                      onTap: () =>
                          _selectDate(context, state.selectedBirthDate),
                      child: AbsorbPointer(
                        child: CommonTextField(
                          controller: _dobController,
                          hint: "Select birth date",
                          disabledBorderColor: context.colors.primary,
                          enabledBorderColor: context.colors.primary,
                          validator: (value) {
                            return _validateAge(state.selectedBirthDate);
                          },
                          prefixIcon: BaseBox(
                            width: 32,
                            height: 32,
                            radius: 10,
                            padding: const EdgeInsets.all(4),
                            backgroundColor: context.colors.primary,
                            child: const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          // suffixIcon: const Icon(
                          //   Icons.keyboard_arrow_down,
                          //   color: Colors.grey,
                          // ),
                        ),
                      ),
                    ),
                    // Show age validation error immediately
                    if (state.selectedBirthDate != null &&
                        _validateAge(state.selectedBirthDate) != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _validateAge(state.selectedBirthDate)!,
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    16.kh,

                    // Phone Number
                    "Phone number".s(15).w(600),
                    12.kh,
                    CommonTextField(
                      controller: _phoneController,
                      disabledBorderColor: context.colors.primary,
                      enabledBorderColor: context.colors.primary,
                      hint: "+998",
                      mask: "+998##-###-##-##",
                      keyboardType: TextInputType.phone,
                      prefixIcon: BaseBox(
                        width: 32,
                        height: 32,
                        radius: 10,
                        padding: const EdgeInsets.all(4),
                        backgroundColor: context.colors.primary,
                        child: Assets.icons.call.svg(),
                      ),
                    ),
                    16.kh,

                    // Gender with Radio Buttons
                    "Gender".s(15).w(600),
                    12.kh,
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              context
                                  .read<ChildrenCubit>()
                                  .changeGender("Male");
                            },
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: "Male",
                                  groupValue: state.selectedGender,
                                  onChanged: (value) {
                                    context
                                        .read<ChildrenCubit>()
                                        .changeGender(value!);
                                  },
                                  activeColor: context.colors.primary,
                                ),
                                8.kw,
                                "Male".s(14).w(500),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              context
                                  .read<ChildrenCubit>()
                                  .changeGender("Female");
                            },
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: "Female",
                                  groupValue: state.selectedGender,
                                  onChanged: (value) {
                                    context
                                        .read<ChildrenCubit>()
                                        .changeGender(value!);
                                  },
                                  activeColor: context.colors.primary,
                                ),
                                8.kw,
                                "Female".s(14).w(500),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    16.kh,

                    // City
                    "City".s(15).w(600),
                    12.kh,
                    CommonTextField(
                      controller: _cityController,
                      enabledBorderColor: context.colors.primary,
                      disabledBorderColor: context.colors.primary,
                      hint: "Tashkent",
                      validator: (value) => _validateRequired(value, 'City'),
                      prefixIcon: BaseBox(
                        width: 32,
                        height: 32,
                        radius: 10,
                        padding: const EdgeInsets.all(4),
                        backgroundColor: context.colors.primary,
                        child: Assets.icons.location.svg(),
                      ),
                    ),
                    16.kh,

                    // District
                    "District".s(15).w(600),
                    12.kh,
                    CommonTextField(
                      controller: _districtController,
                      enabledBorderColor: context.colors.primary,
                      disabledBorderColor: context.colors.primary,
                      hint: "Yakkasaroy",
                      validator: (value) =>
                          _validateRequired(value, 'District'),
                      prefixIcon: BaseBox(
                        width: 32,
                        height: 32,
                        radius: 10,
                        padding: const EdgeInsets.all(4),
                        backgroundColor: context.colors.primary,
                        child: Assets.icons.location.svg(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BottomBox(
              child: CommonButton.elevated(
                loading: state.buttonLoading,
                onPressed: state.buttonLoading
                    ? null
                    : () => _handleSubmit(
                        context, state.selectedGender, state.selectedBirthDate),
                text: childModel != null ? "Yangilash" : "Qo'shish",
              ),
            )
          ],
        ),
      ),
    );
  }
}
