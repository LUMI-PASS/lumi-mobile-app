import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/avatar_notifier.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/avatar_picker.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/common/widget/shaker.dart';
import 'package:lumi_pass/common/widget/topic_chips.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/interest_topic/interest_topic.dart';
import 'package:lumi_pass/presentation/app/profile/profile_detail/cubit/profile_detail_cubit.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';

import 'cubit/profile_detail_state.dart';

/// "Мои информации" — the account screen reached from Profile → "Tahrirlash".
///
/// The profile page has already loaded the parent, so [user] is handed over on
/// navigation and the screen never refetches it — it only writes.
///
/// The first name is editable and the phone stays read-only. Below them the
/// parent answers "what are you looking for?" — asked here, once, rather than
/// again for every child.
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
  void init(BuildContext context) {
    context.read<ProfileDetailCubit>().loadInterestTopics();
  }

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
      appBar: BaseAppBar(
        title: 'my_info'.tr(),
        actions: [
          appBarDeleteAction(
            context,
            enabled: !state.success,
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
      body: _AccountForm(
        user: user,
        saving: state.success,
        topics: state.interestTopics,
      ),
    );
  }
}

/// Confirms the delete, then hands it to `ProfileCubit` by popping `true`.
Future<void> _confirmDeleteAccount(BuildContext context) async {
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DeleteAccountSheet(),
  );
  if (confirmed == true && context.mounted) {
    context.router.maybePop(true);
  }
}

class _AccountForm extends StatefulWidget {
  const _AccountForm({
    required this.user,
    required this.saving,
    required this.topics,
  });

  final HomForUser user;
  final bool saving;

  /// Every word the adminka offers, of either kind. Empty while loading, and
  /// on a server with none — in which case the question is left out.
  final List<InterestTopic> topics;

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


  /// Shaken, never explained in red, when the question is left unanswered.
  final _interestsShake = GlobalKey<ShakerState>();

  /// Topic ids, in the order they were picked — the feed deals its row out
  /// in it.
  late final List<String> _interests = [...?widget.user.interests];

  /// What this form asks about: what the PARENT is looking for. The child's
  /// own interests are asked on each child.
  List<InterestTopic> get _offered => widget.topics
      .where((topic) => topic.topicKind == InterestTopicKind.parent)
      .toList();

  @override
  void dispose() {
    _firstNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleInterest(String id) {
    setState(() {
      if (!_interests.remove(id)) _interests.add(id);
    });
  }

  Future<void> _save() async {
    // At least one — of the words actually offered. With none to offer there
    // is nothing to require, and the name saves as it always did.
    final offered = _offered.map((topic) => topic.id).toSet();
    if (offered.isNotEmpty && !_interests.any(offered.contains)) {
      FocusManager.instance.primaryFocus?.unfocus();
      final target = _interestsShake.currentContext;
      if (target != null) {
        await Scrollable.ensureVisible(
          target,
          alignment: 0.1,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
      _interestsShake.currentState?.shake();
      return;
    }

    context.read<ProfileDetailCubit>().updateProfile(
          HomForUser(
            id: widget.user.id,
            firstName: _firstNameController.text.trim(),
            lastName: widget.user.lastName,
            phoneNumber: widget.user.phoneNumber,
            interests: _interests,
          ),
        );
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
                ValueListenableBuilder<String?>(
                  valueListenable: parentAvatarNotifier,
                  builder: (_, __, ___) => AvatarPicker(
                    pickedFile: parentAvatarFile(),
                    size: 88,
                    onPicked: setParentAvatar,
                  ),
                ),
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
                if (_offered.isNotEmpty) ...[
                  16.kh,
                  Shaker(
                    key: _interestsShake,
                    child: Container(
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
                            'parent_needs_title'.tr(),
                            style: AppText.semibold16
                                .copyWith(color: colors.textPrimary),
                          ),
                          14.kh,
                          TopicChips(
                            topics: _offered,
                            selected: _interests,
                            onToggle: _toggleInterest,
                          ),
                        ],
                      ),
                    ),
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
