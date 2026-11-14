import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_enums.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/new_coins/new_coins_repository.dart';

/// The coin ledger: every purchase, bonus, spend and expiry, newest first.
///
/// Embedded under the balance rather than behind a link — the question it
/// answers, "where did my coins go?", is asked right where the balance is
/// shown. It sits inside the host screen's own scroll view, so it pages with
/// a "show more" row instead of a scroll listener of its own.
class NewCoinsHistoryList extends StatefulWidget {
  const NewCoinsHistoryList({super.key});

  @override
  State<NewCoinsHistoryList> createState() => _NewCoinsHistoryListState();
}

class _NewCoinsHistoryListState extends State<NewCoinsHistoryList> {
  final NewCoinsRepository _repo = getIt<NewCoinsRepository>();

  final List<NewCoinTransaction> _items = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final page = await _repo.getTransactions(page: _page + 1);
      if (!mounted) return;
      setState(() {
        _page = page.page;
        _items.addAll(page.items);
        // An empty page ends the list whatever `total` claims, so a count that
        // drifted can never leave this spinning.
        _hasMore = page.hasMore && page.items.isNotEmpty;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // First page in flight: the list's own shape, shimmering — a date pill
    // and a few cards — rather than a spinner in an empty sheet.
    if (_items.isEmpty && _loading) return const _HistoryShimmer();

    if (_items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: _failed
              ? _more('retry'.tr())
              : Text(
                  'new_coins_history_empty'.tr(),
                  textAlign: TextAlign.center,
                  style: AppText.regular14.copyWith(color: c.textSecondary),
                ),
        ),
      );
    }

    // Grouped by day under a band, newest first — the ledger already comes
    // sorted, so a header goes wherever the day changes.
    DateTime? day(NewCoinTransaction tx) {
      final at = tx.createdAt?.toLocal();
      return at == null ? null : DateTime(at.year, at.month, at.day);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          if (day(_items[i]) != null &&
              (i == 0 || day(_items[i]) != day(_items[i - 1])))
            _DayHeader(day: day(_items[i])!, first: i == 0),
          _TransactionRow(tx: _items[i]),
        ],
        if (_hasMore || _failed)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _more(_failed ? 'retry'.tr() : 'new_coins_history_more'.tr()),
          ),
      ],
    );
  }

  Widget _more(String label) => TextButton(
        onPressed: _loadMore,
        child: Text(
          label,
          style: AppText.medium14.copyWith(color: AppColors.brandPurple),
        ),
      );
}

/// The history's loading state: its own layout — a date pill over cards with
/// a badge, two lines and an amount — in the bookings list's shimmer colours.
class _HistoryShimmer extends StatelessWidget {
  const _HistoryShimmer();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Shimmer paints every shape in one gradient, so it wraps only the
    // placeholders — the cards under them stay solid, as the real ones are.
    Widget shimmer(Widget child) => Shimmer.fromColors(
          baseColor: c.border,
          highlightColor: c.surface,
          child: child,
        );
    Widget bar(double width, double height, {double radius = 6}) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: c.border,
            borderRadius: BorderRadius.circular(radius.r),
          ),
        );
    Widget card() => Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: shimmer(
            Row(
              children: [
                bar(40.w, 40.w, radius: 12),
                12.kw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [bar(150.w, 13.h), 7.kh, bar(90.w, 11.h)],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [bar(44.w, 13.h), 7.kh, bar(32.w, 11.h)],
                ),
              ],
            ),
          ),
        );
    Widget pill() => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Center(child: shimmer(bar(84.w, 30.h, radius: 48))),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [pill(), card(), card(), 8.kh, pill(), card(), card()],
    );
  }
}

/// "Bugun", "Kecha", "9 Noyabr" — a band over one day's rows.
class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.first});

  final DateTime day;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final label = day == today
        ? Strings.notificationToday
        : day == today.subtract(const Duration(days: 1))
            ? Strings.notificationYesterday
            : day.toRussianShortFormat(context);
    // The notifications page's date pill, so the two dated lists read alike.
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : 8.h, bottom: 12.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(48.r),
          ),
          child: Text(
            label,
            style: AppText.medium12.copyWith(color: c.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.tx});

  final NewCoinTransaction tx;

  bool get _isShop => tx.orderType == NewCoinOrderType.shop;

  /// What kind of movement this was, in words.
  String get _kindLabel => switch (tx.kind) {
        NewCoinTransactionKind.spend when _isShop => 'new_coins_tx_shop'.tr(),
        NewCoinTransactionKind.refund when _isShop =>
          'new_coins_tx_shop_refund'.tr(),
        _ => tx.kind.labelKey.tr(),
      };

  /// What the coins went on or came from: the activity, the merch, the pack.
  String? get _subject => switch (tx.orderType) {
        NewCoinOrderType.activity => tx.activityName,
        NewCoinOrderType.shop => tx.itemName,
        NewCoinOrderType.unknown => tx.packName,
      };

  /// The line under the name. An activity payment needs no more than where:
  /// the day is in the pill above, and coins pay for nothing but activities.
  /// Every other row says what kind of movement it was.
  String _subtitle(BuildContext context) {
    final branch = tx.branchName;
    if (tx.kind == NewCoinTransactionKind.spend &&
        tx.orderType == NewCoinOrderType.activity &&
        branch != null) {
      return branch;
    }
    if (_isShop && (tx.itemCount ?? 0) > 1) {
      return '$_kindLabel · ${'shop_n_items'.tr(args: ['${tx.itemCount}'])}';
    }
    return _kindLabel;
  }

  /// The badge: a glyph and a tint per movement, in the wallet history's
  /// palette — spending in brand purple, coins in in green, coins lost in red.
  (IconData, Color) get _badge => switch (tx.kind) {
        NewCoinTransactionKind.spend when _isShop => (
            Icons.shopping_bag_outlined,
            AppColors.brandPurple,
          ),
        NewCoinTransactionKind.spend => (
            Icons.event_available_rounded,
            AppColors.brandPurple,
          ),
        NewCoinTransactionKind.expire => (
            Icons.hourglass_disabled,
            AppColors.error,
          ),
        NewCoinTransactionKind.refund => (
            Icons.replay_rounded,
            AppColors.green
          ),
        NewCoinTransactionKind.bonus => (
            Icons.card_giftcard_rounded,
            AppColors.green,
          ),
        NewCoinTransactionKind.purchase => (
            Icons.toll_rounded,
            AppColors.green,
          ),
        NewCoinTransactionKind.grant || NewCoinTransactionKind.revoke => (
            Icons.tune_rounded,
            AppColors.brandPink
          ),
        NewCoinTransactionKind.unknown => (
            Icons.receipt_long_outlined,
            AppColors.inkMuted,
          ),
      };

  /// Opens the booking or the shop order behind the row, when there is one.
  VoidCallback? _onTap(BuildContext context) {
    final orderId = tx.orderId;
    final shopOrderId = tx.shopOrderId;
    return switch (tx.orderType) {
      NewCoinOrderType.activity when orderId != null => () =>
          context.router.push(BookingDetailRoute(orderId: orderId)),
      NewCoinOrderType.shop when shopOrderId != null => () =>
          context.router.push(ShopOrderRoute(orderId: shopOrderId)),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final incoming = tx.amount >= 0;
    final (icon, tint) = _badge;
    final at = tx.createdAt?.toLocal();

    // A card like a notification's: surface, 12 radius, lifted by a faint
    // shadow in light mode only.
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap(context),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: c.isDark
                ? null
                : [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // The wallet history's badge: the kind's tint washed behind it.
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 20.w, color: tint),
              ),
              12.kw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _subject ?? _kindLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.semibold15.copyWith(color: c.textPrimary),
                    ),
                    3.kh,
                    Text(
                      _subtitle(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.regular13.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              12.kw,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CoinAmount(
                    amount: tx.amount.abs(),
                    prefix: incoming ? '+' : '−',
                    style: AppText.semibold15,
                    color: incoming ? AppColors.green : c.textPrimary,
                  ),
                  3.kh,
                  // A spend later given back says so where its time would be;
                  // the refund itself is its own row.
                  if (tx.refunded)
                    Text(
                      'new_coins_refunded'.tr(),
                      style: AppText.medium13.copyWith(color: AppColors.green),
                    )
                  else if (at != null)
                    Text(
                      DateFormat('HH:mm').format(at),
                      style: AppText.regular13.copyWith(color: c.textSecondary),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
