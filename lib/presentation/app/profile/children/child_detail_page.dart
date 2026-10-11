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
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
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
import 'package:lumi_pass/common/widget/shaker.dart';
import 'package:lumi_pass/common/widget/topic_chips.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/interest_topic/interest_topic.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_state.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';

/// "Детали ребёнка" — name, age, gender and interests for one child, reached from the
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
  void init(BuildContext context) {
    context.read<ChildrenCubit>().loadInterestTopics();
  }

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
      // The save button stays where it is and the keyboard covers it, rather
      // than riding up on top of the keyboard; the form scrolls clear instead.
      resizeToAvoidBottomInset: false,
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
      body: _ChildForm(
        child: child,
        saving: state.buttonLoading,
        topics: state.interestTopics,
      ),
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
  const _ChildForm({
    required this.child,
    required this.saving,
    required this.topics,
  });

  final ChildModel? child;
  final bool saving;

  /// Every word the adminka offers, of either kind. Empty while loading, and
  /// on a server with none — in which case the section is left out and
  /// nothing is required.
  final List<InterestTopic> topics;

  @override
  State<_ChildForm> createState() => _ChildFormState();
}

class _ChildFormState extends State<_ChildForm> {
  static const _male = 'MALE';
  static const _maxAge = 17;
  static const _maxNameLength = 50;
  static const _female = 'FEMALE';

  // What is still owed is shown by shaking it, never by a line of red text:
  // one key per thing a save can be refused for.
  final _nameShake = GlobalKey<ShakerState>();
  final _ageShake = GlobalKey<ShakerState>();
  final _interestsShake = GlobalKey<ShakerState>();

  late final _firstNameController = TextEditingController(
    text: widget.child?.firstName ?? '',
  );
  late final _ageController = TextEditingController(
    text: (widget.child?.age ?? getAge(widget.child?.dob))?.toString() ?? '',
  );
  late String _gender =
      (widget.child?.gender ?? '').toUpperCase() == _female ? _female : _male;

  /// Topic ids, in the order they were picked — the order is kept, because
  /// the feed deals its row out in it.
  late final List<String> _interests = [...?widget.child?.interests];

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

  /// The age as typed, or null while it is empty. [_AgeInputFormatter] keeps
  /// anything outside 1–17 from being typed, so the range check here only
  /// catches a value that arrived from the server.
  int? get _age {
    final n = int.tryParse(_ageController.text.trim());
    return n == null || n < 1 || n > _maxAge ? null : n;
  }

  /// What this form asks about: the child's own interests. What the PARENT
  /// is looking for is asked once, on their profile, not here per child.
  List<InterestTopic> get _offered => widget.topics
      .where((topic) => topic.topicKind == InterestTopicKind.child)
      .toList();

  void _toggleInterest(String id) {
    setState(() {
      if (!_interests.remove(id)) _interests.add(id);
    });
  }

  void _save() {
    final firstName = _firstNameController.text.trim();
    final age = _age;

    // Top of the form first: an empty name and an empty age shake together,
    // and the questions further down wait until those two are in.
    final owed = [
      if (firstName.isEmpty) _nameShake,
      if (age == null) _ageShake,
    ];
    if (owed.isEmpty) {
      // At least one topic — but only of the ones actually offered. A topic
      // the adminka has since retired stays on the child without counting
      // here, and with no topics to offer there is nothing to require.
      final offered = _offered.map((t) => t.id).toSet();
      if (offered.isNotEmpty && !_interests.any(offered.contains)) {
        owed.add(_interestsShake);
      }
    }
    if (owed.isNotEmpty) {
      _flag(owed);
      return;
    }

    final dob = dobForAge(age!);
    final cubit = context.read<ChildrenCubit>();

    // A child saved while this form still asked the parent's question carries
    // those answers too. They live on the parent now, so they are dropped
    // here rather than kept where nothing can untick them.
    final parentTopics = widget.topics
        .where((topic) => topic.topicKind == InterestTopicKind.parent)
        .map((topic) => topic.id)
        .toSet();
    final interests =
        _interests.where((id) => !parentTopics.contains(id)).toList();

    final child = _isEdit
        ? widget.child!.copyWith(
            firstName: firstName,
            dob: dob,
            gender: _gender,
            interests: interests,
          )
        : ChildModel(
            firstName: firstName,
            dob: dob,
            gender: _gender,
            interests: interests,
          );

    cubit.saveChild(child, _isEdit, _photo);
  }

  /// Brings the first of [owed] on screen, then shakes all of them at once.
  /// The keyboard is dropped first — it would be covering the questions.
  Future<void> _flag(List<GlobalKey<ShakerState>> owed) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final target = owed.first.currentContext;
    if (target != null) {
      await Scrollable.ensureVisible(
        target,
        alignment: 0.1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    for (final key in owed) {
      key.currentState?.shake();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16.w,
              12.h,
              16.w,
              24.h + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: AvatarPicker(
                    pickedFile: _photo,
                    imageUrl: _serverPhotoUrl,
                    size: 88,
                    onPicked: (file) => setState(() => _photo = file),
                  ),
                ),
                24.kh,
                // Neither field has a validator: a wrong value cannot be
                // typed, and an empty one is shaken on save.
                Shaker(
                  key: _nameShake,
                  child: CommonTextField(
                    controller: _firstNameController,
                    background: colors.surface,
                    hint: 'first_name'.tr(),
                    hintColor: AppColors.textMuted,
                    enabledBorderColor: Colors.transparent,
                    needToCapitalize: true,
                    inputFormatter: [
                      LengthLimitingTextInputFormatter(_maxNameLength),
                    ],
                  ),
                ),
                12.kh,
                Shaker(
                  key: _ageShake,
                  child: CommonTextField(
                    controller: _ageController,
                    background: colors.surface,
                    hint: 'age'.tr(),
                    hintColor: AppColors.textMuted,
                    enabledBorderColor: Colors.transparent,
                    keyboardType: TextInputType.number,
                    suffixText: 'years_suffix'.tr(),
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      const _AgeInputFormatter(_maxAge),
                    ],
                  ),
                ),
                12.kh,
                Row(
                  children: [
                    Expanded(
                      child: _GenderTile(
                        label: 'child_gender_boy'.tr(),
                        image: Assets.images.childBoy,
                        selected: _gender == _male,
                        onTap: () => setState(() => _gender = _male),
                      ),
                    ),
                    12.kw,
                    Expanded(
                      child: _GenderTile(
                        label: 'child_gender_girl'.tr(),
                        image: Assets.images.childGirl,
                        selected: _gender == _female,
                        onTap: () => setState(() => _gender = _female),
                      ),
                    ),
                  ],
                ),
                if (_offered.isNotEmpty) ...[
                  16.kh,
                  Shaker(
                    key: _interestsShake,
                    child: _interestsCard(colors),
                  ),
                ],
              ],
            ),
          ),
        ),
        BottomBox(
          child: GradientButton(
            text: 'save_button'.tr(),
            gradient: AppGradients.indigo,
            loading: widget.saving,
            onPressed: _save,
          ),
        ),
      ],
    );
  }
}

/// Lets an age be typed only while it stays within 1–[max]: "0" and "18" are
/// refused at the keyboard, so the form never has to explain a range.
class _AgeInputFormatter extends TextInputFormatter {
  const _AgeInputFormatter(this.max);

  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final n = int.tryParse(newValue.text);
    return n == null || n < 1 || n > max ? oldValue : newValue;
  }
}

extension on _ChildFormState {
  /// The question and the words that answer it, on a card of their own.
  Widget _interestsCard(AppColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'child_interests_title'.tr(),
            style: AppText.semibold16.copyWith(color: colors.textPrimary),
          ),
          14.kh,
          TopicChips(
            topics: _offered,
            selected: _interests,
            onToggle: _toggleInterest,
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

/// Half of the boy / girl choice: the child's picture over the word. The
/// picked one is filled with the indigo of the plans screen — the same one
/// that paints the picked topics and the save button, so the screen has one
/// accent; the other rests on the card colour with its picture dimmed.
class _GenderTile extends StatelessWidget {
  const _GenderTile({
    required this.label,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final AssetGenImage image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Bouncing(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
        decoration: BoxDecoration(
          color: selected ? null : colors.surface,
          gradient: selected ? AppGradients.indigo : null,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: selected ? 1 : 0.55,
              child: image.image(width: 76.w, height: 76.w),
            ),
            8.kh,
            Text(
              label,
              style: AppText.semibold14.copyWith(
                color: selected ? AppColors.onBrand : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
