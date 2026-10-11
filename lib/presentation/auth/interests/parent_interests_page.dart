import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/shaker.dart';
import 'package:lumi_pass/common/widget/topic_chips.dart';
import 'package:lumi_pass/data/api_model/interest_topic/interest_topic.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/presentation/app/widgets/bottom_box.dart';

/// Where every way of signing in ends: into the app — by way of
/// [ParentInterestsPage] for an account that was created just now.
///
/// Shared by the SMS code and the Telegram bot, like `applySignedInSession`
/// before it, so a new account is asked the same question whichever door it
/// came through.
///
/// The words are fetched BEFORE the screen is pushed: a server with none to
/// offer (or one that cannot be reached) sends the user straight in, rather
/// than onto a screen that would have nothing to ask.
Future<void> enterAppAfterSignIn(BuildContext context) async {
  final router = context.router;
  final storage = getIt<Storage>();
  // Set by `applySignedInSession` for a brand-new account, and still unread
  // at this point — MainPage consumes it later.
  // An existing account owes nothing, whatever the last one on this device
  // left behind.
  await storage.interestsOwed
      .set(storage.needsOnboarding.call() == true ? true : null);
  await askInterestsIfOwed(router);
  router.replaceAll(const [MainRoute()]);
}

/// Shows [ParentInterestsPage] if the account still owes its answer, and
/// returns once it has been given.
///
/// Called on the way in from sign-in, and again by MainPage on every launch:
/// an app closed on the question comes back to it instead of slipping past.
Future<void> askInterestsIfOwed(StackRouter router) async {
  final storage = getIt<Storage>();
  if (storage.interestsOwed.call() != true) return;
  final topics = await _parentTopics();
  // Nothing to ask with (yet): the debt stands, and the next launch tries
  // again.
  if (topics.isEmpty) return;
  await router.pushWidget(ParentInterestsPage(topics: topics));
}

Future<List<InterestTopic>> _parentTopics() async {
  try {
    final topics = await getIt<HomeRepository>().getInterestTopics();
    return topics
        .where((topic) => topic.topicKind == InterestTopicKind.parent)
        .toList();
  } catch (_) {
    return const [];
  }
}

/// "What are you looking for?" — the one question a new account is asked
/// before it sees the app, because the home feed's own row is built from the
/// answer.
///
/// There is no way past it but answering: no back, no skip, and closing the
/// app only postpones it (see [askInterestsIfOwed]). The same question stays
/// editable afterwards on "edit my info".
class ParentInterestsPage extends StatefulWidget {
  const ParentInterestsPage({super.key, required this.topics});

  /// The words on offer — never empty; see [enterAppAfterSignIn].
  final List<InterestTopic> topics;

  @override
  State<ParentInterestsPage> createState() => _ParentInterestsPageState();
}

class _ParentInterestsPageState extends State<ParentInterestsPage> {
  /// Topic ids, in the order they were picked.
  final List<String> _interests = [];

  /// Shaken when "continue" is pressed with nothing picked.
  final _chipsShake = GlobalKey<ShakerState>();

  bool _saving = false;

  void _toggle(String id) {
    setState(() {
      if (!_interests.remove(id)) _interests.add(id);
    });
  }

  Future<void> _continue() async {
    if (_interests.isEmpty) {
      _chipsShake.currentState?.shake();
      return;
    }
    setState(() => _saving = true);
    try {
      await getIt<Dio>().patch(
        'users/parents/profile',
        data: {'interests': _interests},
      );
    } catch (_) {
      // A failed save must not strand a new user on the doorstep. They go in
      // without it, and the question is still there on "edit my info".
    }
    // Answered, as far as the app is concerned — even when the save failed,
    // so a server fault cannot bring the screen back on every launch.
    await getIt<Storage>().interestsOwed.set(null);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.scaffoldBg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The mascot asks the question, rather than a heading
                      // sitting over a list: it pops in, and what it says
                      // is the speech bubble beside it.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.elasticOut,
                            builder: (_, value, child) =>
                                Transform.scale(scale: value, child: child),
                            child: Assets.images.mascot.mascotHello.image(
                              width: 96.w,
                              height: 96.w,
                              excludeFromSemantics: true,
                            ),
                          ),
                          10.kw,
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 20.h),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.r),
                                    topRight: Radius.circular(20.r),
                                    bottomRight: Radius.circular(20.r),
                                    // The corner nearest the mascot is the
                                    // bubble's tail.
                                    bottomLeft: Radius.circular(4.r),
                                  ),
                                ),
                                child: Text(
                                  'parent_needs_title'.tr(),
                                  style: AppText.semibold18
                                      .copyWith(color: colors.textPrimary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      20.kh,
                      Shaker(
                        key: _chipsShake,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: TopicChips(
                            topics: widget.topics,
                            selected: _interests,
                            onToggle: _toggle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BottomBox(
                child: GradientButton(
                  text: 'continue'.tr(),
                  gradient: AppGradients.indigo,
                  loading: _saving,
                  onPressed: _continue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
