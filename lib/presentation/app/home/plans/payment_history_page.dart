import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/adaptive_card.dart';
import 'package:lumi_pass/data/api_model/subscription/subscription_record.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/plans/widgets/coupon_history_list.dart';

/// Purchased-coupon history as a page of its own. The same body also renders
/// inline in the History tab of [PlansPage] via [CouponHistoryList].
@RoutePage()
class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final OrdersApi _api = getIt<OrdersApi>();

  List<SubscriptionRecord> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getSubscriptionHistory();
      if (!mounted) return;
      setState(() => _history = data);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => context.router.maybePop()),
            Expanded(
              child: SingleChildScrollView(
                child: CouponHistoryList(
                  records: _history,
                  isLoading: _isLoading,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AdaptiveCard(
              onTap: onBack,
              tone: CardTone.control,
              bordered: true,
              padding: EdgeInsets.all(8.w),
              child: Assets.icons.arrowLeftRounded.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(
                  context.colors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Text(
            'coupon_history_title'.tr(),
            style: AppText.medium16.copyWith(color: context.colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
