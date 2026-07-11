import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';

@RoutePage()
class AddNewCardPage extends StatefulWidget {
  const AddNewCardPage({super.key});

  @override
  State<AddNewCardPage> createState() => _AddNewCardPageState();
}

class _AddNewCardPageState extends State<AddNewCardPage> {
  final _numberCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _numberCtrl.dispose();
    _holderCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  /// Binds the card via WLCM: begin (PAN + expiry → OTP), confirm the OTP, then
  /// pop back to the list. The PAN never leaves this call — only the resulting
  /// token is saved on the backend.
  Future<void> _save() async {
    final pan = _numberCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final mmYy = _expiryCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (pan.length < 16) {
      setState(() => _error = 'pay_card_number_invalid'.tr());
      return;
    }
    if (mmYy.length < 4) {
      setState(() => _error = 'pay_card_expiry_invalid'.tr());
      return;
    }
    // The Subscribe API expects YYMM; the field is entered MM/YY.
    final yyMm = mmYy.substring(2, 4) + mmYy.substring(0, 2);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api = getIt<OrdersApi>();
      final session = await api.addSavedCard(cardNumber: pan, expireDate: yyMm);
      if (!mounted) return;
      final otp = await _promptOtp(session.otpSentPhone);
      if (otp == null || otp.isEmpty) {
        setState(() => _busy = false);
        return;
      }
      await api.confirmSavedCard(
        cid: session.cid,
        otp: otp,
        cardName:
            _holderCtrl.text.trim().isEmpty ? null : _holderCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true); // signal the list to refresh
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ??
              e.message ??
              'card_save_error'.tr())
          : (e.message ?? 'card_save_error'.tr());
      if (mounted) {
        setState(() {
          _busy = false;
          _error = msg;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'card_save_error'.tr();
        });
      }
    }
  }

  /// OTP prompt for the SMS the bank sent the cardholder.
  Future<String?> _promptOtp(String? phone) {
    final c = context.colors;
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('card_confirm_title'.tr(),
            style: TextStyle(color: c.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              phone != null && phone.isNotEmpty
                  ? 'pay_code_sent_to'.tr(args: [phone])
                  : 'pay_code_sent'.tr(),
              style: TextStyle(fontSize: 13.sp, color: c.textSecondary),
            ),
            12.kh,
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(color: c.textPrimary),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                hintText: 'card_sms_hint'.tr(),
                hintStyle: TextStyle(color: c.textPlaceholder),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                Text('cancel'.tr(), style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: Text('card_confirm_action'.tr(),
                style: TextStyle(color: c.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(title: 'card_add_title'.tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PreviewCard(
                number: _numberCtrl.text,
                holder: _holderCtrl.text,
                expiry: _expiryCtrl.text,
              ),
              24.kh,
              Text(
                'card_details'.tr(),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              6.kh,
              Text(
                'card_details_sub'.tr(),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: c.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              22.kh,
              _CardField(
                label: 'card_number_label'.tr(),
                hint: '0000 0000 0000 0000',
                controller: _numberCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(19),
                  _CardNumberFormatter(),
                ],
                onChanged: () => setState(() {}),
                suffix: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child:
                      Assets.icons.mastercard.svg(width: 28.w, height: 28.w),
                ),
              ),
              14.kh,
              _CardField(
                label: 'card_holder_label'.tr(),
                hint: 'card_holder_hint'.tr(),
                controller: _holderCtrl,
                textCapitalization: TextCapitalization.characters,
                onChanged: () => setState(() {}),
              ),
              14.kh,
              Row(
                children: [
                  Expanded(
                    child: _CardField(
                      label: 'card_expiration_label'.tr(),
                      hint: 'MM/YY',
                      controller: _expiryCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryFormatter(),
                      ],
                      onChanged: () => setState(() {}),
                    ),
                  ),
                  12.kw,
                  Expanded(
                    child: _CardField(
                      label: 'CVC',
                      hint: '000',
                      controller: _cvcCtrl,
                      keyboardType: TextInputType.number,
                      obscure: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      onChanged: () => setState(() {}),
                    ),
                  ),
                ],
              ),
              16.kh,
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_rounded, size: 16.sp, color: c.primary),
                    10.kw,
                    Expanded(
                      child: Text(
                        'card_secure_note'.tr(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: c.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                14.kh,
                Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: c.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              28.kh,
              GestureDetector(
                onTap: _busy ? null : _save,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    gradient: LinearGradient(
                      colors: [c.primary, const Color(0xFFFF7093)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: c.primary.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _busy
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'card_save'.tr(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.number,
    required this.holder,
    required this.expiry,
  });

  final String number;
  final String holder;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final maskedNumber =
        number.isEmpty ? '•••• •••• •••• ••••' : number.padRight(19, '•');
    final maskedHolder = holder.isEmpty ? 'FULL NAME' : holder.toUpperCase();
    final maskedExpiry = expiry.isEmpty ? 'MM/YY' : expiry;

    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, const Color(0xFFFF7093)],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Assets.icons.card.svg(width: 36.w, height: 26.h),
              const Spacer(),
              Assets.icons.mastercard.svg(width: 42.w, height: 42.w),
            ],
          ),
          22.kh,
          Text(
            maskedNumber,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          20.kh,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARDHOLDER',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    4.kh,
                    Text(
                      maskedHolder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  4.kh,
                  Text(
                    maskedExpiry,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  const _CardField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
    this.obscure = false,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final bool obscure;
  final TextCapitalization textCapitalization;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: c.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        8.kh,
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscure,
          textCapitalization: textCapitalization,
          onChanged: (_) => onChanged?.call(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: c.textPlaceholder,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: c.surface,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: c.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    String formatted = digits;
    if (digits.length >= 3) {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
