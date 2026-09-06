import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/control_chip.dart';

/// A long body of copy — a class/branch/group description — shown as a
/// dropdown: a few lines by default, the whole thing once expanded.
///
/// Detail screens used to state the same description twice, a two-line
/// ellipsised copy in the title card and the full text again further down.
/// This is the one control that replaces both: the text is stated once, and
/// the reader opens it if they want the rest.
///
/// The chevron sits at BOTH ends — next to [title] at the top, and under the
/// text at the bottom. A long description pushes its own header off-screen
/// once open, so a collapse control that only lives up there can't be reached
/// without scrolling back up.
///
/// Copy short enough to fit inside [collapsedLines] renders as plain text with
/// no chevron at all — there is nothing to open.
class ExpandableDescription extends StatefulWidget {
  const ExpandableDescription({
    super.key,
    required this.text,
    this.title,
    this.titleStyle,
    this.textStyle,
    this.textAlign,
    this.collapsedLines = 3,
    this.compact = false,
  });

  final String text;

  /// Optional header line the top chevron sits beside. Without one the card
  /// above is already the heading, so only the bottom chevron is drawn.
  final String? title;
  final TextStyle? titleStyle;
  final TextStyle? textStyle;
  final TextAlign? textAlign;

  /// How much of the text is shown while collapsed.
  final int collapsedLines;

  /// A bare chevron instead of the [ControlChip] pill — for descriptions
  /// nested inside another card (a course group panel), where the pill would
  /// read as a second, competing control.
  final bool compact;

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  /// Whether [text] actually runs past [collapsedLines] at this width — the
  /// only reason to offer a chevron.
  bool _overflows(String text, TextStyle style, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: widget.collapsedLines,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  Widget _chevron(AppColorScheme c) {
    final icon = AnimatedRotation(
      turns: _expanded ? 0.5 : 0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Assets.icons.arrowDown.svg(
        width: widget.compact ? 16.w : 20.w,
        height: widget.compact ? 16.w : 20.w,
        colorFilter: ColorFilter.mode(
          widget.compact ? c.textSecondary : c.textPrimary,
          BlendMode.srcIn,
        ),
      ),
    );
    if (widget.compact) {
      return Padding(padding: EdgeInsets.all(4.w), child: icon);
    }
    return ControlChip(padding: EdgeInsets.all(8.w), child: icon);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textStyle =
        widget.textStyle ?? AppText.regular14.copyWith(color: c.textPrimary);
    final title = widget.title;

    return LayoutBuilder(
      builder: (context, constraints) {
        final canExpand =
            _overflows(widget.text, textStyle, constraints.maxWidth);

        final body = Text(
          widget.text,
          textAlign: widget.textAlign,
          maxLines: canExpand && !_expanded ? widget.collapsedLines : null,
          overflow: canExpand && !_expanded
              ? TextOverflow.ellipsis
              : TextOverflow.clip,
          style: textStyle,
        );

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: canExpand ? _toggle : null,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: widget.titleStyle ??
                              AppText.semibold16.copyWith(color: c.textPrimary),
                        ),
                      ),
                      if (canExpand) ...[
                        12.horizontalSpace,
                        _chevron(c),
                      ],
                    ],
                  ),
                ),
                6.verticalSpace,
              ],
              // The text itself opens the dropdown too — a truncated paragraph
              // is the thing a reader taps.
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: canExpand ? _toggle : null,
                child: SizedBox(width: double.infinity, child: body),
              ),
              if (canExpand)
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggle,
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: _chevron(c),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
