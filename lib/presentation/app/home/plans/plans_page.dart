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
import 'package:lumi_pass/data/api_model/subscription/subscription_record.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/paycom_checkout_page.dart';
import 'package:shimmer/shimmer.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _green = Color(0xFF16A34A);
const _greenBg = Color(0xFFECFDF5);
const _grey = Color(0xFF64748B);
const _greyBg = Color(0xFFF1F5F9);
const _red = Color(0xFFDC2626);
const _redBg = Color(0xFFFEF2F2);
const _navy = Color(0xFF1E293B);
const _border = Color(0xFFE2E8F0);

@RoutePage()
class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final HomeRepository _repo = getIt<HomeRepository>();
  final OrdersApi _api = getIt<OrdersApi>();

  // Plans tab
  List<PremiumPlan> _plans = [];
  bool _isLoading = true;
  String? _purchasingId;

  // History tab
  List<SubscriptionRecord> _history = [];
  bool _historyLoading = false;
  bool _historyLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_onTabChanged);
    _loadPlans();
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && !_historyLoaded && !_historyLoading) {
      _loadHistory();
    }
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repo.getPremiumPlans();
      if (!mounted) return;
      setState(() => _plans = data.where((p) => p.isActive != false).toList());
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _historyLoading = true);
    try {
      final data = await _api.getSubscriptionHistory();
      if (!mounted) return;
      setState(() {
        _history = data;
        _historyLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _historyLoaded = true);
    } finally {
      if (mounted) setState(() => _historyLoading = false);
    }
  }

  Future<void> _purchase(PremiumPlan plan) async {
    if (plan.id == null || _purchasingId != null) return;
    setState(() => _purchasingId = plan.id);
    try {
      final checkout = await _api.checkoutSubscription(
        tariffId: plan.id!,
        test: true,
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
      // Refresh history after returning from payment
      setState(() {
        _historyLoaded = false;
        _history = [];
      });
      if (_tabController.index == 1) _loadHistory();
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
          Column(
            children: [
              _Header(primary: primary, tabController: _tabController),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _PlansTab(
                      plans: _plans,
                      isLoading: _isLoading,
                      purchasingId: _purchasingId,
                      onChoose: _purchase,
                    ),
                    _HistoryTab(
                      history: _history,
                      isLoading: _historyLoading,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ── Back button ──────────────────────────────────────────────────
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
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
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

// ─── Header with gradient + TabBar ───────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.primary, required this.tabController});

  final Color primary;
  final TabController tabController;

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
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                  child: Row(
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
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.35)),
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
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                            ),
                            6.kh,
                            Text(
                              'coupon_plans_subtitle'.tr(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13.sp,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 88.w,
                        height: 88.w,
                        child: Lottie.asset(
                          'assets/lotties/premium.json',
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                      ),
                    ],
                  ),
                ),
                16.kh,
                // Tab bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TabBar(
                      controller: tabController,
                      labelStyle: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      labelColor: primary,
                      unselectedLabelColor:
                          Colors.white.withValues(alpha: 0.8),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: 'coupon_tab_plans'.tr()),
                        Tab(text: 'coupon_tab_history'.tr()),
                      ],
                    ),
                  ),
                ),
                16.kh,
              ],
            ),
          ),
        ),
        // Decorative motif
        Positioned(
          right: -40,
          top: 20,
          child: Opacity(
            opacity: 0.1,
            child: Assets.icons.background.premiumMisc.svg(
              width: 180.w,
              height: 180.w,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Plans tab ────────────────────────────────────────────────────────────────

class _PlansTab extends StatelessWidget {
  const _PlansTab({
    required this.plans,
    required this.isLoading,
    required this.purchasingId,
    required this.onChoose,
  });

  final List<PremiumPlan> plans;
  final bool isLoading;
  final String? purchasingId;
  final ValueChanged<PremiumPlan> onChoose;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(strokeWidth: 2.5));
    }
    if (plans.isEmpty) {
      return _EmptyPlans();
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
      itemCount: plans.length,
      separatorBuilder: (_, __) => 14.kh,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final popularIndex =
            plans.length >= 2 ? (plans.length ~/ 2) : -1;
        return _PlanCard(
          plan: plan,
          isPopular: index == popularIndex,
          isPurchasing: purchasingId == plan.id,
          disabled: purchasingId != null && purchasingId != plan.id,
          onChoose: () => onChoose(plan),
        );
      },
    );
  }
}

// ─── History tab ─────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({
    required this.history,
    required this.isLoading,
  });

  final List<SubscriptionRecord> history;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _HistoryShimmer();
    }
    if (history.isEmpty) {
      return _EmptyHistory();
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
      itemCount: history.length,
      separatorBuilder: (_, __) => 12.kh,
      itemBuilder: (_, i) => _HistoryCard(record: history[i]),
    );
  }
}

// ─── Subscription history card ────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record});

  final SubscriptionRecord record;

  String _fmtDate(BuildContext context, DateTime d) =>
      d.toRussianShortFormat(context);

  @override
  Widget build(BuildContext context) {
    final r = record;
    final primary = context.colors.primary;

    // Status chip colours
    final Color statusBg;
    final Color statusFg;
    final String statusLabel;
    if (r.isActive) {
      statusBg = _greenBg;
      statusFg = _green;
      statusLabel = 'sub_status_active'.tr();
    } else if (r.isCanceled) {
      statusBg = _redBg;
      statusFg = _red;
      statusLabel = 'sub_status_canceled'.tr();
    } else {
      statusBg = _greyBg;
      statusFg = _grey;
      statusLabel = 'sub_status_expired'.tr();
    }

    // Activity progress
    final hasLimit = r.activitiesLimit > 0;
    final progress = hasLimit
        ? (r.usedCount / r.activitiesLimit).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
            color: r.isActive ? primary.withValues(alpha: 0.25) : _border),
        boxShadow: [
          BoxShadow(
            color: (r.isActive ? primary : Colors.black)
                .withValues(alpha: r.isActive ? 0.07 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: plan name + status ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discount badge circle
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary, const Color(0xFFFF7093)],
                  ),
                ),
                child: Center(
                  child: Text(
                    r.discountPercentage > 0
                        ? '-${r.discountPercentage}%'
                        : '—',
                    style: TextStyle(
                      fontSize: r.discountPercentage >= 10 ? 11.sp : 13.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              12.kw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.planName?.isNotEmpty == true
                          ? r.planName!
                          : 'coupon_plans_title'.tr(),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.kh,
                    Text(
                      r.amount.toRawUzsPrice(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Status pill
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: statusFg,
                  ),
                ),
              ),
            ],
          ),

          16.kh,
          Divider(height: 1, color: _border),
          14.kh,

          // ── Date range ───────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 13.sp, color: _grey),
              6.kw,
              Text(
                '${_fmtDate(context, r.startDate)}  →  ${_fmtDate(context, r.endDate)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: _grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (hasLimit) ...[
            14.kh,
            // ── Activities usage ─────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.event_available_rounded,
                    size: 13.sp, color: _grey),
                6.kw,
                Expanded(
                  child: Text(
                    '${r.usedCount} ${'sub_activities_used'.tr()} ${'sub_activities_of'.tr()} ${r.activitiesLimit} ${'sub_activities_label'.tr()}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: _grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '${r.remaining} left',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: r.remaining > 0 ? _green : _grey,
                  ),
                ),
              ],
            ),
            8.kh,
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6.h,
                backgroundColor: _border,
                valueColor: AlwaysStoppedAnimation(
                  progress >= 1.0 ? _red : primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── History shimmer ──────────────────────────────────────────────────────────

class _HistoryShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
      itemCount: 3,
      separatorBuilder: (_, __) => 12.kh,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Container(
          height: 140.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}

// ─── Empty states ─────────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.receipt_long_rounded,
                  size: 38.sp, color: primary),
            ),
            18.kh,
            Text(
              'sub_history_empty'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: _navy,
              ),
            ),
            8.kh,
            Text(
              'sub_history_empty_hint'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: _grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPlans extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.1),
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
                color: _navy,
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
      ),
    );
  }
}

// ─── Plan card (unchanged logic) ──────────────────────────────────────────────

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
      if ((plan.durationDays ?? 0) > 0) '${plan.durationDays} ${'days'.tr()}',
      if (discount > 0)
        '${'discount_on_activities'.tr()}: ${discount.toStringAsFixed(discount % 1 == 0 ? 0 : 1)}%',
    ];

    final card = Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isPopular ? primary.withValues(alpha: 0) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isPopular ? 0.08 : 0.04),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [primary, const Color(0xFFFF7093)]),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.1),
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
                        color: primary.withValues(alpha: 0.1),
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
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: LinearGradient(
            colors: [primary, const Color(0xFFFF7093)]),
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
        colors: [primary, const Color(0xFFFF7093)]);
    return GestureDetector(
      onTap: (isLoading || disabled) ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          gradient: isPopular ? gradient : null,
          color: isPopular ? null : primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isPopular
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.35),
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
