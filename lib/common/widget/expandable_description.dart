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
/// There is exactly ONE control, and it is always in the same place: the
/// chevron at the top right, on the [title] / [header] line. It is the same
/// accordion marker as the trial-lessons dropdown on class detail — same
/// glyph, same 20pt size, same `textMuted` tint — because it does the same
/// thing. Earlier this widget also drew a second chevron under the text; two
/// controls for one action read as two different actions, and the lower one
/// stretched edge to edge into something that looked like a page button.
///
/// Without a title or header the row holds the chevron alone, right-aligned
/// above the text.
///
/// Copy short enough to fit inside [collapsedLines] renders as plain text with
/// no chevron at all — there is nothing to open.
class ExpandableDescription extends StatefulWidget {
  const ExpandableDescription({
    super.key,
    required this.text,
    this.title,
    this.header,
    this.titleStyle,
    this.textStyle,
    this.textAlign,
    this.collapsedLines = 3,
    this.compact = false,
  });

  final String text;

  /// Optional header line the chevron sits beside.
  final String? title;

  /// Header widget the chevron sits beside — for a section that already has a
  /// built header (a `DetailCardHeader` badge + title). Takes the place of
  /// [title]; giving both draws only this.
  final Widget? header;

  final TextStyle? titleStyle;
  final TextStyle? textStyle;
  final TextAlign? textAlign;

  /// How much of the text is shown while collapsed.
  final int collapsedLines;

  /// A smaller, dimmer chevron — for descriptions nested inside another card
  /// (a course group panel), where the full-size marker would compete with
  /// that card's own controls.
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
        colorFilter: ColorFilter.mode(c.textMuted, BlendMode.srcIn),
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
    final header = widget.header;
    final title = widget.title;
    final hasHeading = header != null || title != null;

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
              if (hasHeading || canExpand) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: canExpand ? _toggle : null,
                  child: Row(
                    children: [
                      Expanded(
                        child: header ??
                            (title == null
                                ? const SizedBox.shrink()
                                : Text(
                                    title,
                                    style: widget.titleStyle ??
                                        AppText.semibold16
                                            .copyWith(color: c.textPrimary),
                                  )),
                      ),
                      if (canExpand) ...[
                        12.horizontalSpace,
                        _chevron(c),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: hasHeading ? 12.h : 4.h),
              ],
              // The text itself opens the dropdown too — a truncated paragraph
              // is the thing a reader taps.
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: canExpand ? _toggle : null,
                child: SizedBox(width: double.infinity, child: body),
              ),
            ],
          ),
        );
      },
    );
  }
}
