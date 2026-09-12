import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// The app's text field: filled, borderless, with the label riding inside it.
///
/// Ported from the Nexus app's `AppTextField` (`packages/nexus_ui_kit`), which
/// is the shape we want here: a 60-high filled box with a 16-radius (or a
/// pill), no outline, a floating label rather than a caption above the field,
/// and the error message BELOW the box rather than inside Material's own
/// `errorText` slot — so a field never changes height when it goes invalid and
/// a form never jumps under the user's thumb.
///
/// Rewritten against Lumi's own tokens rather than copied: colours come from
/// [AppColorScheme] roles so the field is correct in dark mode, sizes go
/// through screenutil, and text uses [AppText]. Two deliberate departures from
/// the original:
///
///  * [focusNode] is OPTIONAL. Nexus requires one from every caller, which
///    means every screen using a field also owns a StatefulWidget just to hold
///    it. This makes its own when none is given, so a plain form is a plain
///    form.
///  * Validity is expressed as [errorText] alone. Nexus carries both an
///    `isValueValid` flag and an `errorMessage`, which can disagree — a field
///    marked invalid with no message renders an empty red gap, and one with a
///    message but `isValueValid: true` shows nothing. One source of truth
///    cannot contradict itself.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.focusNode,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.showClearButton = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.isPill = false,
    this.bordered = false,
    this.height,
  });

  /// Rides inside the box and shrinks on focus — not a caption above it.
  final String? label;

  /// Shown only once the label has floated, so the two never overlap.
  final String? placeholder;

  final TextEditingController? controller;

  /// Optional: one is created and disposed internally when omitted.
  final FocusNode? focusNode;

  /// The single source of truth for validity. Non-null tints the box, colours
  /// the label, and prints the message underneath.
  final String? errorText;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Makes the field a picker row: it stops taking the keyboard and taps run
  /// this instead. Pair it with a chevron in [suffixIcon].
  final VoidCallback? onTap;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  /// An ✕ while the field has focus and content. Ignored when [suffixIcon] is
  /// set — one slot, and the caller's icon wins.
  final bool showClearButton;

  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// Fully rounded, for search bars and chips-like inputs.
  final bool isPill;

  /// Adds the hairline outline, for a field on an already-filled surface where
  /// the fill alone would not separate it.
  final bool bordered;

  /// Defaults to 60. A multi-line field ignores it and grows instead — a fixed
  /// height would clip the second line.
  final double? height;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  FocusNode? _ownedNode;
  TextEditingController? _ownedController;

  FocusNode get _node => widget.focusNode ?? (_ownedNode ??= FocusNode());
  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());

  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      _node.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _node.removeListener(_onFocusChanged);
    // Only what this widget made. Disposing a caller's node or controller
    // would break the screen that still owns it.
    _ownedNode?.dispose();
    _ownedController?.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() => _focused = _node.hasFocus);
  }

  bool get _isInvalid => (widget.errorText ?? '').isNotEmpty;
  bool get _isMultiline => (widget.maxLines ?? 1) != 1;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(widget.isPill ? 100.r : 16.r);

    // A tint of the error colour rather than a solid one: the field still has
    // to read as an input, not as an alert.
    final background = _isInvalid
        ? c.error.withValues(alpha: 0.08)
        : _focused
            ? c.controlBorder
            : c.control;

    final foreground = widget.enabled && !widget.readOnly
        ? c.textPrimary
        : c.textMuted;

    final labelColour = _isInvalid
        ? c.error
        : !widget.enabled || widget.readOnly
            ? c.textMuted
            : _focused
                ? c.textPrimary
                : c.textPlaceholder;

    final field = TextField(
      controller: _controller,
      focusNode: _node,
      enabled: widget.enabled,
      // A tap target that runs [onTap] must not also raise the keyboard.
      readOnly: widget.readOnly || widget.onTap != null,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      cursorColor: c.primary,
      style: AppText.regular14.copyWith(color: foreground),
      // Tapping the page background should put the keyboard away; without this
      // the field keeps focus and the sheet stays up.
      onTapOutside: (_) => _node.unfocus(),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.placeholder,
        // The box draws the frame; Material must not draw a second one.
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        isDense: true,
        counterText: '',
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        labelStyle: AppText.regular12.copyWith(color: labelColour),
        floatingLabelStyle: AppText.regular12.copyWith(color: labelColour),
        hintStyle: AppText.regular14.copyWith(color: c.textPlaceholder),
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.w),
        suffixIcon: _suffix(c.textSecondary),
        // Material otherwise reserves a 48×48 box in the suffix slot and
        // stretches whatever is in it to fill; tight constraints let an icon
        // keep the size it was given.
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: _isMultiline ? null : (widget.height ?? 60.h),
          alignment: _isMultiline ? null : Alignment.center,
          padding: EdgeInsets.only(
            left: widget.prefixIcon == null ? (widget.isPill ? 20.w : 12.w) : 0,
            right: 12.w,
            // A growing field needs its own vertical breathing room, since it
            // has no fixed height to centre within.
            top: _isMultiline ? 4.h : 0,
            bottom: _isMultiline ? 4.h : 0,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: radius,
            border: widget.bordered ? Border.all(color: c.controlBorder) : null,
          ),
          child: field,
        ),
        if (_isInvalid) ...[
          4.kh,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              widget.errorText!,
              style: AppText.regular12.copyWith(color: c.error),
            ),
          ),
        ],
      ],
    );
  }

  /// The caller's icon, else the clear button when there is something to clear.
  Widget? _suffix(Color tint) {
    if (widget.suffixIcon != null) return widget.suffixIcon;
    if (!widget.showClearButton || !_focused) return null;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (_, value, __) {
        if (value.text.isEmpty) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () {
            _controller.clear();
            widget.onChanged?.call('');
          },
          child: Padding(
            padding: EdgeInsets.only(right: widget.isPill ? 20.w : 12.w),
            child: Icon(Icons.cancel, size: 18.w, color: tint),
          ),
        );
      },
    );
  }
}
