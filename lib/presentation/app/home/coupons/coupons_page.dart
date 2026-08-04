import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/widget/pill_card.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/payment_sheets.dart';

@RoutePage()
class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  _PromoResult? _result;
  String? _errorMessage;

  /// Payment method the buyer means to redeem this coupon with, picked from
  /// the same rail chooser the order checkout uses. Nothing is charged here —
  /// redeeming still happens at checkout, per `coupon_apply_at_checkout`.
  PaymentSelection? _payment;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _focusNode.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _result = null;
      _errorMessage = null;
    });
    _animCtrl.reset();

    try {
      final dio = getIt<Dio>();
      final response = await dio.post('promocodes/validate', data: {
        'code': code.toUpperCase(),
        'subtotal': 999999999,
      });
      final raw = response.data;
      final data = raw is Map && raw['data'] is Map
          ? Map<String, dynamic>.from(raw['data'] as Map)
          : <String, dynamic>{};
      if (mounted) {
        setState(() {
          _result = _PromoResult.fromJson(data);
          _isLoading = false;
        });
        _animCtrl.forward();
      }
    } on DioException catch (e) {
      String msg = 'coupon_invalid_title'.tr();
      if (e.response?.data is Map) {
        final body = e.response!.data as Map;
        final message = body['message'] ?? body['error'];
        if (message is String && message.isNotEmpty) msg = message;
      }
      if (mounted) {
        setState(() {
          _errorMessage = msg;
          _isLoading = false;
        });
        _animCtrl.forward();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'coupon_invalid_title'.tr();
          _isLoading = false;
        });
        _animCtrl.forward();
      }
    }
  }

  /// Opens the same rail chooser used at order checkout. It only picks — it
  /// never charges — so this stays a plain selection stored in state.
  Future<void> _choosePayment() async {
    final picked = await showPaymentChooser(
      context,
      initial: _payment,
      cardsComingSoon: !kCardPaymentsEnabled,
    );
    if (picked == null || !mounted) return;
    setState(() => _payment = picked);
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(primary: primary, onBack: () => context.router.maybePop())),
            SliverToBoxAdapter(
              child: _InputSection(
                controller: _codeCtrl,
                focusNode: _focusNode,
                isLoading: _isLoading,
                primary: primary,
                onCheck: _check,
              ),
            ),
            if (_result != null || _errorMessage != null)
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      child: _result != null
                          ? Column(
                              children: [
                                _SuccessCard(result: _result!, primary: primary),
                                16.kh,
                                _PaymentMethodSection(
                                  payment: _payment,
                                  onTap: _choosePayment,
                                ),
                              ],
                            )
                          : _ErrorCard(message: _errorMessage!),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(child: _HowToUseSection(primary: primary)),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom + 32.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.primary, required this.onBack});

  final Color primary;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, const Color(0xFFFF7093)],
            ),
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(36.r)),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12.h,
            left: 20.w,
            right: 20.w,
            bottom: 32.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.chevron_left,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
              24.kh,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.35)),
                          ),
                          child: Text(
                            'coupons_title'.tr().toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                        12.kh,
                        Text(
                          'coupons_title'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        8.kh,
                        Text(
                          'coupons_subtitle'.tr(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13.sp,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.kw,
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.ticket_fill,
                      size: 40.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: -40,
          bottom: -30,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.12,
              child: Assets.icons.background.premiumMisc.svg(
                width: 200.w,
                height: 200.w,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Input section ───────────────────────────────────────────────────────────

class _InputSection extends StatelessWidget {
  const _InputSection({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.primary,
    required this.onCheck,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final Color primary;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'coupon_enter_code'.tr(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF91A2C3),
                letterSpacing: 0.3,
              ),
            ),
            10.kh,
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F5FF),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: primary.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9]')),
                        UpperCaseTextFormatter(),
                      ],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E3D5D),
                        letterSpacing: 2.0,
                      ),
                      decoration: InputDecoration(
                        hintText: 'WELCOME10',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFFBBC2D0),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(13.w),
                          child: Icon(
                            CupertinoIcons.ticket,
                            size: 20.sp,
                            color: primary,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14.h, horizontal: 8.w),
                      ),
                      onSubmitted: (_) => onCheck(),
                    ),
                  ),
                ),
                10.kw,
                GestureDetector(
                  onTap: isLoading ? null : onCheck,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, const Color(0xFFFF7093)],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.32),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'coupon_check_btn'.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Success card ─────────────────────────────────────────────────────────────

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.result, required this.primary});

  final _PromoResult result;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final isPercent = result.discountType == 'percent';
    final discountLabel = isPercent
        ? '${result.discountValue.toInt()}%'
        : '${_formatPrice(result.discountValue)} UZS';

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF43A047).withOpacity(0.08),
            const Color(0xFF1B5E20).withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFF43A047).withOpacity(0.28),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  size: 24.sp,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              12.kw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'coupon_valid_title'.tr(),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    6.kh,
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        result.code.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2E7D32),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          14.kh,
          // Discount showcase
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Column(
              children: [
                Icon(CupertinoIcons.tag_fill, size: 28.sp, color: primary),
                8.kh,
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: discountLabel,
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w900,
                          color: primary,
                          height: 1.0,
                        ),
                      ),
                      TextSpan(
                        text: '  ${'coupon_discount_off'.tr()}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          14.kh,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.info_circle,
                  size: 14.sp, color: Colors.grey.shade400),
              6.kw,
              Expanded(
                child: Text(
                  'coupon_apply_at_checkout'.tr(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double v) {
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)} mln';
    }
    if (v >= 1000) {
      final s = v.toInt().toString();
      return '${s.substring(0, s.length - 3)} ${s.substring(s.length - 3)}';
    }
    return v.toInt().toString();
  }
}

// ─── Payment method row ─────────────────────────────────────────────────────

/// The rail picker row, shown once a coupon validates — the same [PillCard]
/// shape and [showPaymentChooser] sheet the order checkout uses (Payme,
/// Click, Uzum, card), so the buyer picks how they mean to pay before they
/// ever reach checkout.
class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection({required this.payment, required this.onTap});

  final PaymentSelection? payment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PillCard(
      onTap: onTap,
      leading: PillIconBadge(child: _leading(payment)),
      child: PillCaption(
        title: payment == null ? 'coupon_pick_payment'.tr() : payment!.rail.brandName,
        subtitle: 'coupon_pay_method_label'.tr(),
        captionFirst: true,
        titleColor: payment == null ? AppColors.greeting : null,
      ),
      trailing: PillActionChip(
        label: payment == null ? 'book_choose'.tr() : 'book_change'.tr(),
        onTap: onTap,
      ),
    );
  }

  /// Rail brand mark, or a neutral card glyph while nothing is picked yet
  /// (same square marks the booking row uses — the pill badge is too narrow
  /// for the full wordmarks).
  Widget _leading(PaymentSelection? p) {
    switch (p?.rail) {
      case PaymentRail.payme:
        return Assets.images.pay.paymeLogo.image(width: 22.w, height: 22.w);
      case PaymentRail.click:
        return Assets.images.pay.clickLogo.image(width: 22.w, height: 22.w);
      case PaymentRail.uzum:
        return Assets.images.pay.uzumLogo.image(width: 22.w, height: 22.w);
      case PaymentRail.card:
      case null:
        return Icon(CupertinoIcons.creditcard, size: 20.sp, color: AppColors.ink);
    }
  }
}

// ─── Error card ───────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F3), Color(0xFFFFF5F5)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFFFF7093).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7093).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.xmark_circle_fill,
              size: 22.sp,
              color: const Color(0xFFE53935),
            ),
          ),
          12.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'coupon_invalid_title'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE53935),
                  ),
                ),
                if (message.isNotEmpty &&
                    message != 'coupon_invalid_title'.tr()) ...[
                  6.kh,
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── How-to-use section ───────────────────────────────────────────────────────

class _HowToUseSection extends StatelessWidget {
  const _HowToUseSection({required this.primary});

  final Color primary;

  static const _steps = [
    'coupon_step1',
    'coupon_step2',
    'coupon_step3',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.question_circle_fill,
                    size: 16.sp,
                    color: primary,
                  ),
                ),
                10.kw,
                Text(
                  'coupon_how_title'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E3D5D),
                  ),
                ),
              ],
            ),
            18.kh,
            ...List.generate(_steps.length, (i) {
              final isLast = i == _steps.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primary, const Color(0xFFFF7093)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 1.5,
                          height: 28.h,
                          color: primary.withOpacity(0.15),
                        ),
                    ],
                  ),
                  12.kw,
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 4.h, bottom: isLast ? 0 : 16.h),
                      child: Text(
                        _steps[i].tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF4B5563),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _PromoResult {
  final String code;
  final String discountType;
  final double discountValue;
  final double discountAmount;
  final double totalAmount;

  const _PromoResult({
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.totalAmount,
  });

  factory _PromoResult.fromJson(Map<String, dynamic> json) {
    return _PromoResult(
      code: json['code'] as String? ?? '',
      discountType: json['discount_type'] as String? ?? 'percent',
      discountValue: (json['discount_value'] as num? ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] as num? ?? 0).toDouble(),
      totalAmount: (json['total_amount'] as num? ?? 0).toDouble(),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
