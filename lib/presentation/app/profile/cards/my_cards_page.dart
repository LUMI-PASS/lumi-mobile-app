import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/data/api_model/order/saved_card.dart';
import 'package:lumi_pass/presentation/app/profile/cards/cubit/my_cards_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/cards/cubit/my_cards_state.dart';
import 'package:lumi_pass/presentation/app/profile/cards/widgets/add_card_sheet.dart';
import 'package:lumi_pass/presentation/app/profile/cards/widgets/card_row.dart';
import 'package:lumi_pass/presentation/app/profile/cards/widgets/delete_card_sheet.dart';

/// The user's saved cards.
///
/// Adding one costs a real 100-soum charge on the card (that is how this
/// gateway proves a card exists), so the flow is deliberately explicit: the add
/// sheet says so before the user commits, and nothing is saved until the bank's
/// code is confirmed.
@RoutePage()
class MyCardsPage
    extends BasePage<MyCardsCubit, MyCardsBuildable, MyCardsListenable> {
  const MyCardsPage({super.key});

  @override
  void init(BuildContext context) {
    context.read<MyCardsCubit>().load();
    super.init(context);
  }

  @override
  void listener(BuildContext context, MyCardsListenable state) {
    if (state.effect == MyCardsEffect.deleteFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message ?? 'card_delete_error'.tr())),
      );
    }
    super.listener(context, state);
  }

  Future<void> _add(BuildContext context) async {
    final cubit = context.read<MyCardsCubit>();
    final saved = await showAddCardSheet(context);
    if (saved != null) await cubit.onCardAdded();
  }

  Future<void> _delete(BuildContext context, SavedCard card) async {
    final cubit = context.read<MyCardsCubit>();
    final ok = await showDeleteCardSheet(context, card);
    if (ok == true) await cubit.remove(card);
  }

  @override
  Widget builder(BuildContext context, MyCardsBuildable state) {
    final c = context.colors;
    final cubit = context.read<MyCardsCubit>();

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(
        title: 'my_cards'.tr(),
        actions: [
          if (state.isAvailable && state.cards.isNotEmpty)
            IconButton(
              onPressed: () => _add(context),
              icon: Icon(Icons.add_rounded,
                  size: 24.sp, color: AppColors.brandPurple),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.brandPurple,
        onRefresh: cubit.refresh,
        child: _body(context, state, c),
      ),
    );
  }

  Widget _body(
      BuildContext context, MyCardsBuildable state, AppColorScheme c) {
    if (state.isLoading) {
      return Center(child: CircularProgressIndicator(color: c.primary));
    }
    if (state.error != null) {
      return _Message(
        icon: state.isAvailable
            ? Icons.wifi_off_rounded
            : Icons.credit_card_off_rounded,
        title: state.error!,
        // A 503 is not retryable by the user — don't offer a button that
        // can only fail again.
        actionLabel: state.isAvailable ? 'card_retry'.tr() : null,
        onAction: state.isAvailable
            ? () => context.read<MyCardsCubit>().load()
            : null,
      );
    }
    if (state.isEmpty) {
      return _Message(
        icon: Icons.credit_card_rounded,
        title: 'card_none'.tr(),
        subtitle: 'card_none_sub'.tr(),
        actionLabel: 'card_add_new'.tr(),
        onAction: () => _add(context),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      children: [
        // One grouped container with dividers, rather than a card per row —
        // saved cards are a settings list, not a gallery.
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: c.divider),
          ),
          child: Column(
            children: [
              for (var i = 0; i < state.cards.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16.w,
                    endIndent: 16.w,
                    color: c.divider,
                  ),
                CardRow(
                  card: state.cards[i],
                  isRemoving: state.removingId == state.cards[i].id,
                  onDelete: () => _delete(context, state.cards[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Shared empty / error state — an icon, a sentence, and at most one action.
class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Stays scrollable so pull-to-refresh still works on an empty list.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 80.h),
      children: [
        Icon(icon, size: 48.sp, color: c.textPlaceholder),
        16.kh,
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppText.semibold16.copyWith(color: c.textPrimary),
        ),
        if (subtitle != null) ...[
          8.kh,
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: AppText.regular13
                .copyWith(color: c.textSecondary, height: 1.4),
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          24.kh,
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 28.w, vertical: 13.h),
                decoration: BoxDecoration(
                  color: AppColors.brandPurple,
                  borderRadius: BorderRadius.circular(44.r),
                ),
                child: Text(
                  actionLabel!,
                  style: AppText.medium16.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
