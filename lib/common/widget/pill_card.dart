import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';

/// The frosted "pill row" from the Figma booking design: a fully-rounded
/// [FrostedCard] laying out a round icon badge, a two-line caption and an
/// optional trailing chip.
///
/// It is the single shape behind the ticket-tariff rows, the payment-method row
/// and the promocode row — build those with this widget instead of re-declaring
/// the gradient + white border on a raw [Container].
class PillCard extends StatelessWidget {
  const PillCard({
    super.key,
    required this.leading,
    required this.child,
    this.trailing,
    this.onTap,
  });

  /// Round icon badge on the left — usually a [PillIconBadge].
  final Widget leading;

  /// Main content; expands to fill the row. Usually a [PillCaption].
  final Widget child;

  /// Optional right-hand affordance — usually a [PillActionChip] or a stepper.
  final Widget? trailing;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40.r),
      borderWidth: 2,
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
      child: Row(
        children: [
          leading,
          8.kw,
          Expanded(child: child),
          if (trailing != null) ...[8.kw, trailing!],
        ],
      ),
    );
  }
}

/// White circular badge holding a 20px glyph — the leading element of a
/// [PillCard].
class PillIconBadge extends StatelessWidget {
  const PillIconBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.onBrand,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

/// The two stacked labels inside a [PillCard].
///
/// [PillCard] is always a light frosted surface, so the text uses the
/// theme-independent [AppColors.ink] / [AppColors.greeting] pair rather than
/// theme tokens — otherwise the labels would turn white on a pale card in dark
/// mode.
class PillCaption extends StatelessWidget {
  const PillCaption({
    super.key,
    required this.title,
    this.subtitle,
    this.captionFirst = false,
    this.titleColor,
    this.subtitleColor,
  });

  /// The emphasised line (tariff label, payment-rail name).
  final String title;

  /// The muted line (price, "Payment method"). Omit for a single-line caption.
  final String? subtitle;

  /// Put [subtitle] *above* [title] — the payment row reads
  /// "Payment method" / **Paymee**, the inverse of a tariff row.
  final bool captionFirst;

  final Color? titleColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title,
      style: AppText.semibold14.copyWith(color: titleColor ?? AppColors.ink),
    );
    final sub = subtitle;
    if (sub == null) return titleText;

    final subtitleText = Text(
      sub,
      style: AppText.regular12
          .copyWith(color: subtitleColor ?? AppColors.greeting),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: captionFirst
          ? [subtitleText, 4.kh, titleText]
          : [titleText, 4.kh, subtitleText],
    );
  }
}

/// Small inset chip punched into a [PillCard] — "Change" / "Apply".
class PillActionChip extends StatelessWidget {
  const PillActionChip({
    super.key,
    required this.label,
    this.onTap,
    this.child,
  });

  final String label;
  final VoidCallback? onTap;

  /// Replaces the label — used to show a spinner while the action runs.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.inkChip,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: child ??
            Text(
              label,
              style: AppText.semibold12.copyWith(color: AppColors.ink),
            ),
      ),
    );
  }
}
