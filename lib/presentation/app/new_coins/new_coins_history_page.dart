import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
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

    if (_items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : _failed
                  ? _more('retry'.tr())
                  : Text(
                      'new_coins_history_empty'.tr(),
                      textAlign: TextAlign.center,
                      style: AppText.regular14.copyWith(color: c.textSecondary),
                    ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          if (i > 0) Divider(height: 1, color: c.border),
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

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.tx});

  final NewCoinTransaction tx;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final incoming = tx.amount >= 0;
    final createdAt = tx.createdAt;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.kind.labelKey.tr(),
                  style: AppText.medium14.copyWith(color: c.textPrimary),
                ),
                if (createdAt != null) ...[
                  2.kh,
                  Text(
                    createdAt.toRussianShortFormat(context),
                    style: AppText.regular12.copyWith(color: c.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CoinAmount(
                amount: tx.amount.abs(),
                prefix: incoming ? '+' : '−',
                style: AppText.semibold14,
                color: incoming ? AppColors.green : c.textPrimary,
              ),
              2.kh,
              Text(
                'new_coins_balance_line'
                    .tr(args: [tx.balanceAfter.toGrouped()]),
                style: AppText.regular12.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
