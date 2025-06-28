import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:chess_ui_kit/src/services/number_masking.dart';
import 'package:chess_ui_kit/src/utils/text_field_extension.dart';
import 'package:flutter/material.dart';

enum TextFieldType { text, phone }

class ChessTextField extends StatefulWidget {
  final Widget? suffixIcon;
  final Widget? suffix;
  final Widget? prefixIcon;
  final TextFieldType type;
  final FocusNode focusNode;
  final String? errorMessage;
  final String? label;
  final String? placeholder;
  final double? height;
  final bool isValueValid;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextEditingController? controller;
  final void Function(Country?)? onCountrySelect;
  final TextInputType textInputType;
  final bool readOnly;
  final bool showClearButton;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final bool autofocus;

  const ChessTextField({
    super.key,
    this.suffixIcon,
    this.prefixIcon,
    this.errorMessage,
    required this.focusNode,
    this.label,
    this.placeholder,
    this.height,
    this.controller,
    this.onChanged,
    this.suffix,
    this.isValueValid = true,
    this.readOnly = false,
    this.showClearButton = false,
    this.textInputAction,
    this.onSubmitted,
    this.maxLines = 1,
    this.autofocus = false,
  })  : onCountrySelect = null,
        textInputType = TextInputType.text,
        type = TextFieldType.text;

  const ChessTextField.phone({
    super.key,
    this.errorMessage,
    required this.focusNode,
    this.placeholder,
    this.height,
    required this.controller,
    this.onChanged,
    this.suffix,
    this.onCountrySelect,
    this.isValueValid = true,
    this.readOnly = false,
    this.textInputAction,
    this.onSubmitted,
    this.maxLines = 1,
    this.autofocus = false,
  })  : showClearButton = true,
        prefixIcon = null,
        label = null,
        suffixIcon = null,
        textInputType = TextInputType.phone,
        type = TextFieldType.phone;

  @override
  State<ChessTextField> createState() => _ChessTextFieldState();
}

class _ChessTextFieldState extends State<ChessTextField> {
  bool _focused = false;
  late Country _selectedCountry;
  late MaskTextInputFormatter _maskingFormat;

  @override
  void initState() {
    _maskingFormat = MaskTextInputFormatter(
      mask: '(##) ###-##-##',
      type: MaskAutoCompletionType.lazy,
    );

    widget.focusNode.addListener(() {
      if (mounted) {
        setState(() => _focused = widget.focusNode.hasFocus);
      }
    });

    _loadInitialCountry();

    super.initState();
  }

  void _loadInitialCountry() async {
    const initialCountry = Constants.uzbekistan;

    widget.onCountrySelect?.call(initialCountry);
    setState(() => _selectedCountry = initialCountry);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height ?? 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isPhoneType) ...[
                Flexible(
                  child: AddressSelector.dialCode(
                    title: "Davlatni tanlang",
                    titleTextStyle: context.textTheme.bodyRegular
                        .copyWith(color: ChessColors.black),
                    subtitleTextStyle: context.textTheme.subheadlineRegular
                        .copyWith(color: ChessColors.black),
                    selectedCountry: _selectedCountry,
                    onItemSelect: (country) {
                      if (country != null) {
                        widget.controller!.clear();
                        setState(() => _selectedCountry = country);
                        widget.onCountrySelect?.call(_selectedCountry);
                      }
                    },
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: ChessColors.greyG40,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: FlagImage.getImage(
                                countryCode: _selectedCountry.code,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedCountry.dialCode,
                            style: context.textTheme.bodyRegular,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                flex: 3,
                child: Container(
                  alignment: Alignment.center,
                  padding: widget.prefixIcon == null
                      ? const EdgeInsets.only(left: 12)
                      : null,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: widget.backgroundColor(hasFocus: _focused),
                  ),
                  child: TextField(
                    maxLines: widget.maxLines,
                    inputFormatters: [
                      if (widget.isPhoneType &&
                          widget.checkMaskCountry(country: _selectedCountry))
                        _maskingFormat
                    ],
                    textInputAction: widget.textInputAction,
                    readOnly: widget.readOnly,
                    autofocus: widget.autofocus,
                    keyboardType: widget.textInputType,
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: ChessColors.primaryDefault,
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    style: context.textTheme.bodyRegular.copyWith(
                      color: widget.foregroundColor,
                    ),
                    onTapOutside: (_) => widget.focusNode.unfocus(),
                    decoration: InputDecoration(
                      labelText: widget.label,
                      hintText: widget.placeholder ,
                      prefixIcon: widget.prefixIcon,
                      suffixIconColor: widget.foregroundColor,
                      prefixIconColor: widget.foregroundColor,
                      border: InputBorder.none,
                      suffixIcon: widget.showClearButton && _focused
                          ? GestureDetector(
                              onTap: () => widget.controller!.clear(),
                              child: ChessUiKitAssets.icons.general.xFilled.svg(
                                fit: BoxFit.none,
                              ),
                            )
                          : widget.suffixIcon,
                      hintStyle: context.textTheme.bodyRegular.copyWith(
                        color: widget.labelColor() ,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minHeight: 36,
                        minWidth: 36,
                      ),
                      labelStyle: context.textTheme.footnoteRegular.copyWith(
                        color: widget.labelColor(hasFocus: _focused),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!widget.isValueValid) ...[
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              widget.errorMessage!,
              style: context.textTheme.caption1Regular.copyWith(
                color: ChessColors.errorDefault,
                fontSize: 12,
              ),
            ),
          )
        ]
      ],
    );
  }
}
