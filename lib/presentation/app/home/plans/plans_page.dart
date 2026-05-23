import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/data/api_model/premium_plan/premium_plan_model.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/paycom_checkout_page.dart';

@RoutePage()
class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  final HomeRepository _repo = getIt<HomeRepository>();

  List<PremiumPlan> _plans = [];
  bool _isLoading = true;
  String? _purchasingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repo.getPremiumPlans();
      if (!mounted) return;
      setState(() => _plans = data.where((p) => p.isActive != false).toList());
    } catch (_) {
      // Leave empty list — empty state will render.
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _purchase(PremiumPlan plan) async {
    if (plan.id == null || _purchasingId != null) return;
    setState(() => _purchasingId = plan.id);
    try {
      final checkout = await getIt<OrdersApi>().checkoutSubscription(
        tariffId: plan.id!,
        test: true, // TODO: flip to false before production
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaycomCheckoutPage(
            result: checkout,
            isSubscription: true,
            planDiscountPercentage: plan.discountPercentage?.round(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), maxLines: 3),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      if (mounted) setState(() => _purchasingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7FC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(primary: primary)),
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              else if (_plans.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
                  sliver: SliverList.separated(
                    itemCount: _plans.length,
                    separatorBuilder: (_, __) => 14.kh,
                    itemBuilder: (context, index) {
                      final plan = _plans[index];
                      final popularIndex = _plans.length >= 2
                          ? (_plans.length ~/ 2)
                          : -1;
                      return _PlanCard(
                        plan: plan,
                        isPopular: index == popularIndex,
                        isPurchasing: _purchasingId == plan.id,
                        disabled: _purchasingId != null && _purchasingId != plan.id,
                        onChoose: () => _purchase(plan),
                      );
                    },
                  ),
                ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 8.w,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () => context.router.maybePop(),
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: primary,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.primary});

  final Color primary;

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
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(36.r)),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 24.h,
            left: 20.w,
            right: 20.w,
            bottom: 28.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        36.kh,
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
                            'coupon_plans_title'.tr().toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                        14.kh,
                        Text(
                          'coupon_plans_title'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        10.kh,
                        Text(
                          'coupon_plans_subtitle'.tr(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14.sp,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 96.w,
                    height: 96.w,
                    child: Lottie.asset(
                      'assets/lotties/premium.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Decorative pattern motif bleeding into the header
        Positioned(
          right: -40,
          bottom: -30,
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
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isPopular,
    required this.isPurchasing,
    required this.disabled,
    required this.onChoose,
  });

  final PremiumPlan plan;
  final bool isPopular;
  final bool isPurchasing;
  final bool disabled;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final discount = plan.discountPercentage ?? 0;
    final features = <String>[
      if ((plan.activitiesLimit ?? 0) > 0)
        '${plan.activitiesLimit} ${'activities_limit'.tr()}',
      if ((plan.durationDays ?? 0) > 0)
        '${plan.durationDays} ${'days'.tr()}',
      if (discount > 0)
        '${'discount_on_activities'.tr()}: ${discount.toStringAsFixed(discount % 1 == 0 ? 0 : 1)}%',
    ];

    final card = Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isPopular
              ? primary.withOpacity(0.0)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isPopular ? 0.08 : 0.04),
            blurRadius: isPopular ? 24 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.localizedTitle,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E3D5D),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (isPopular)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, const Color(0xFFFF7093)],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded,
                          size: 12.sp, color: Colors.white),
                      4.kw,
                      Text(
                        'popular'.tr().toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          14.kh,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (plan.price ?? 0).toRawUzsPrice(),
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w900,
                  color: primary,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              8.kw,
              if (discount > 0)
                Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '-${discount.toStringAsFixed(discount % 1 == 0 ? 0 : 1)}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (features.isNotEmpty) ...[
            16.kh,
            ...features.map(
              (f) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 3.h),
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          size: 12.sp, color: primary),
                    ),
                    8.kw,
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF4B5563),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          16.kh,
          SizedBox(
            width: double.infinity,
            child: _ChooseButton(
              isPopular: isPopular,
              isLoading: isPurchasing,
              disabled: disabled,
              onPressed: onChoose,
            ),
          ),
        ],
      ),
    );

    if (!isPopular) return card;
    // Gradient outline for popular card
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: LinearGradient(
          colors: [primary, const Color(0xFFFF7093)],
        ),
      ),
      child: card,
    );
  }
}

class _ChooseButton extends StatelessWidget {
  const _ChooseButton({
    required this.isPopular,
    required this.isLoading,
    required this.disabled,
    required this.onPressed,
  });

  final bool isPopular;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final gradient = LinearGradient(
      colors: [primary, const Color(0xFFFF7093)],
    );
    return GestureDetector(
      onTap: (isLoading || disabled) ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          gradient: isPopular ? gradient : null,
          color: isPopular ? null : primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isPopular
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      isPopular ? Colors.white : primary,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'get_coupon'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: isPopular ? Colors.white : primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    6.kw,
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16.sp,
                      color: isPopular ? Colors.white : primary,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88.w,
            height: 88.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.workspace_premium_outlined,
              size: 44.sp,
              color: primary,
            ),
          ),
          20.kh,
          Text(
            'no_plans_yet'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E3D5D),
            ),
          ),
          10.kh,
          Text(
            'no_plans_hint'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

