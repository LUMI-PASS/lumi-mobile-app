import 'dart:io';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/constants/constants.dart';
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
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isEdit => childModel != null;

  @override
  void init(context) {
    _initializeControllers(context);
    context.read<ChildrenCubit>().getChildren();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _initializeControllers(BuildContext context) {
    _firstNameController.text = childModel?.firstName ?? '';
    _lastNameController.text = childModel?.lastName ?? '';

    if (childModel?.dob != null && childModel!.dob!.isNotEmpty) {
      try {
        final selectedDate = DateTime.parse(childModel!.dob!);
        context.read<ChildrenCubit>().setBirthDate(selectedDate);
        _dobController.text =
            "${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}";
      } catch (e) {
        context.read<ChildrenCubit>().setBirthDate(null);
        _dobController.text = '';
      }
    }

    if (childModel?.gender != null && childModel!.gender!.isNotEmpty) {
      context.read<ChildrenCubit>().changeGender(
          childModel!.gender!.toUpperCase() == 'MALE' ? 'MALE' : 'FEMALE');
    } else {
      context.read<ChildrenCubit>().changeGender('MALE');
    }

    // Reset stepper
    context.read<ChildrenCubit>().setStep(0);
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'field_required'.tr(args: [fieldName]);
    }
    if (value.trim().length > 50) {
      return 'max_50_chars'.tr(args: [fieldName]);
    }
    return null;
  }

  String? _validateAge(DateTime? selectedDate) {
    if (selectedDate == null) {
      return 'dob_required'.tr();
    }
    final now = DateTime.now();
    if (selectedDate.isAfter(now)) {
      return 'date_future_error'.tr();
    }
    final age = now.year - selectedDate.year;
    final hasHadBirthdayThisYear = now.month > selectedDate.month ||
        (now.month == selectedDate.month && now.day >= selectedDate.day);
    final actualAge = hasHadBirthdayThisYear ? age : age - 1;
    if (actualAge > 16) {
      return 'child_max_age'.tr();
    }
    if (actualAge < 0) {
      return 'invalid_birth_date'.tr();
    }
    return null;
  }

  Future<void> _selectDate(
      BuildContext context, DateTime? currentSelectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentSelectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 8)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
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

    if (picked != null) {
      context.read<ChildrenCubit>().setBirthDate(picked);
      _dobController.text =
          "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
    }
  }

  void _handleFormSubmit(BuildContext context, String gender,
      DateTime? selectedDate, ChildrenBuildable state) {
    final ageError = _validateAge(selectedDate);
    if (ageError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ageError), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final childData = ChildModel(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      gender: gender.toUpperCase(),
      dob: DateFormat("yyyy-MM-dd").format(selectedDate!),
      city: state.parentCity.isNotEmpty ? state.parentCity : 'Tashkent',
      district: state.parentDistrict.isNotEmpty ? state.parentDistrict : 'Tashkent',
    );

    if (_isEdit) {
      final updated = childModel!.copyWith(
        firstName: childData.firstName,
        lastName: childData.lastName,
        gender: childData.gender,
        dob: childData.dob,
        city: childData.city,
      );
      context.read<ChildrenCubit>().submit(updated, true);
    } else {
      context.read<ChildrenCubit>().addChildAndGetId(childData);
    }
  }

  @override
  void listener(BuildContext context, ChildrenListenable state) {
    if (state.effect == ChildrenEffect.verify) {
      // Edit update done -> go to photo step or pop
      if (_isEdit) {
        context.read<ChildrenCubit>().setStep(1);
      } else {
        context.router.pop();
      }
    }
    if (state.effect == ChildrenEffect.photoUploaded) {
      context.router.pop();
    }
    super.listener(context, state);
  }

  @override
  Widget builder(context, state) {
    final isPhotoStep = state.currentStep == 1;

    return Scaffold(
      appBar: BaseAppBar(
        title: _isEdit
            ? (isPhotoStep ? 'update_photo'.tr() : 'update_child'.tr())
            : (isPhotoStep ? 'add_photo'.tr() : 'add_child'.tr()),
      ),
      body: Column(
        children: [
          // Stepper indicator
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: _StepperIndicator(
              currentStep: state.currentStep,
              steps: ["child_info".tr(), "photo".tr()],
            ),
          ),

          Expanded(
            child: isPhotoStep
                ? _PhotoUploadStep(
                    childId: _isEdit ? childModel?.id : state.newChildId,
                    isLoading: state.buttonLoading,
                    hasExistingPhoto: _isEdit && childModel?.hasPhoto == true,
                    existingPhotoUrl: _isEdit && childModel?.hasPhoto == true
                        ? '${Constants.baseUrl}assets/files/child-photo/${childModel!.id}'
                        : null,
                    onUpload: (file) {
                      final id = _isEdit ? childModel?.id : state.newChildId;
                      if (id != null) {
                        context
                            .read<ChildrenCubit>()
                            .uploadChildPhoto(id, file);
                      }
                    },
                    onDone: () => context.router.pop(),
                  )
                : _buildForm(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, ChildrenBuildable state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First Name
                  'first_name'.tr().s(13).w(600),
                  8.kh,
                  CommonTextField(
                    controller: _firstNameController,
                    hint: 'enter_first_name'.tr(),
                    needToCapitalize: true,
                    background: context.colors.onPrimary,
                    validator: (value) =>
                        _validateRequired(value, 'First name'),
                  ),
                  16.kh,

                  // Last Name
                  'last_name'.tr().s(13).w(600),
                  8.kh,
                  CommonTextField(
                    controller: _lastNameController,
                    hint: 'enter_last_name'.tr(),
                    needToCapitalize: true,
                    background: context.colors.onPrimary,
                    validator: (value) =>
                        _validateRequired(value, 'Last name'),
                  ),
                  16.kh,

                  // Date of Birth - tap to show calendar
                  'date_of_birth'.tr().s(13).w(600),
                  8.kh,
                  GestureDetector(
                    onTap: () =>
                        _selectDate(context, state.selectedBirthDate),
                    child: AbsorbPointer(
                      child: CommonTextField(
                        controller: _dobController,
                        hint: 'select_dob'.tr(),
                        background: context.colors.onPrimary,
                        validator: (_) =>
                            _validateAge(state.selectedBirthDate),
                      ),
                    ),
                  ),
                  16.kh,

                  // Gender
                  'gender'.tr().s(13).w(600),
                  12.kh,
                  Row(
                    children: [
                      _GenderChip(
                        label: 'male'.tr(),
                        icon: Icons.male_rounded,
                        isSelected: state.selectedGender == "MALE",
                        onTap: () => context
                            .read<ChildrenCubit>()
                            .changeGender("MALE"),
                        color: context.colors.primary,
                      ),
                      12.kw,
                      _GenderChip(
                        label: 'female'.tr(),
                        icon: Icons.female_rounded,
                        isSelected: state.selectedGender == "FEMALE",
                        onTap: () => context
                            .read<ChildrenCubit>()
                            .changeGender("FEMALE"),
                        color: context.colors.primary,
                      ),
                    ],
                  ),
                  24.kh,
                ],
              ),
            ),
          ),

          // Bottom buttons
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
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
                          : () => _handleFormSubmit(
                              context,
                              state.selectedGender,
                              state.selectedBirthDate,
                              state),
                      text: 'next'.tr(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stepper indicator
class _StepperIndicator extends StatelessWidget {
  const _StepperIndicator({
    required this.currentStep,
    required this.steps,
  });

  final int currentStep;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = index ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              color: stepIndex < currentStep
                  ? context.colors.primary
                  : Colors.grey.shade300,
            ),
          );
        }

        final stepIndex = index ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;
        final isActive = isCompleted || isCurrent;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? context.colors.primary : Colors.grey.shade100,
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check_rounded, size: 18.w, color: Colors.white)
                    : Icon(
                        stepIndex == 0
                            ? Icons.person_outline_rounded
                            : Icons.camera_alt_outlined,
                        size: 18.w,
                        color: isCurrent ? Colors.white : Colors.grey.shade400,
                      ),
              ),
            ),
            6.kh,
            steps[stepIndex]
                .s(11)
                .w(600)
                .c(isActive ? context.colors.primary : Colors.grey.shade400),
          ],
        );
      }),
    );
  }
}

/// Gender chip with icon
class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20.w,
                color: isSelected ? Colors.white : Colors.grey.shade500,
              ),
              8.kw,
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Photo upload step - required for add, editable for edit
class _PhotoUploadStep extends StatefulWidget {
  const _PhotoUploadStep({
    required this.childId,
    required this.isLoading,
    required this.hasExistingPhoto,
    required this.existingPhotoUrl,
    required this.onUpload,
    required this.onDone,
  });

  final String? childId;
  final bool isLoading;
  final bool hasExistingPhoto;
  final String? existingPhotoUrl;
  final ValueChanged<File> onUpload;
  final VoidCallback onDone;

  @override
  State<_PhotoUploadStep> createState() => _PhotoUploadStepState();
}

class _PhotoUploadStepState extends State<_PhotoUploadStep> {
  File? _selectedPhoto;
  final _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _selectedPhoto = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_to_pick_photo'.tr())),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _selectedPhoto = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_to_pick_photo'.tr())),
        );
      }
    }
  }

  ImageProvider? _resolveImage() {
    if (_selectedPhoto != null) {
      return FileImage(_selectedPhoto!);
    }
    if (widget.hasExistingPhoto && widget.existingPhotoUrl != null) {
      return NetworkImage(widget.existingPhotoUrl!);
    }
    return null;
  }

  bool get _hasAnyPhoto => _selectedPhoto != null || widget.hasExistingPhoto;

  @override
  Widget build(BuildContext context) {
    final image = _resolveImage();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Photo preview circle
                GestureDetector(
                  onTap: _pickFromGallery,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 150.w,
                    height: 150.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade50,
                      border: Border.all(
                        color: _hasAnyPhoto
                            ? context.colors.primary
                            : Colors.grey.shade300,
                        width: _hasAnyPhoto ? 3 : 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: image != null
                        ? Image(
                            image: image,
                            fit: BoxFit.cover,
                            width: 150.w,
                            height: 150.w,
                            errorBuilder: (_, __, ___) => _emptyPhotoContent(),
                          )
                        : _emptyPhotoContent(),
                  ),
                ),
                if (_hasAnyPhoto) ...[
                  12.kh,
                  GestureDetector(
                    onTap: _pickFromGallery,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 14.w, color: context.colors.primary),
                        4.kw,
                        'change_photo'.tr()
                            .s(13)
                            .w(500)
                            .c(context.colors.primary),
                      ],
                    ),
                  ),
                ],
                28.kh,
                // Pick options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PhotoOptionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'gallery'.tr(),
                      onTap: _pickFromGallery,
                      color: context.colors.primary,
                    ),
                    32.kw,
                    _PhotoOptionButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'camera'.tr(),
                      onTap: _pickFromCamera,
                      color: context.colors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom action
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: SizedBox(
                width: double.infinity,
                child: _selectedPhoto != null
                    ? CommonButton.elevated(
                        loading: widget.isLoading,
                        onPressed: !widget.isLoading
                            ? () => widget.onUpload(_selectedPhoto!)
                            : null,
                        text: widget.hasExistingPhoto
                            ? 'update_photo'.tr()
                            : 'upload_photo'.tr(),
                      )
                    : widget.hasExistingPhoto
                        ? CommonButton.outlined(
                            onPressed: widget.onDone,
                            text: 'keep_current_photo'.tr(),
                            textColor: context.colors.primary,
                            borderColor:
                                context.colors.primary.withOpacity(0.3),
                          )
                        : CommonButton.elevated(
                            onPressed: null,
                            text: 'upload_photo'.tr(),
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyPhotoContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          size: 40.w,
          color: Colors.grey.shade400,
        ),
        6.kh,
        'tap_to_add'.tr().s(11).c(Colors.grey.shade400),
      ],
    );
  }
}

class _PhotoOptionButton extends StatelessWidget {
  const _PhotoOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(icon, color: color, size: 28.w),
          ),
          8.kh,
          label.s(12).w(500).c(Colors.grey.shade600),
        ],
      ),
    );
  }
}
