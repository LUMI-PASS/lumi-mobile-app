import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/new_coins/new_coins_repository.dart';

/// The coin ledger: every purchase, bonus, spend and expiry, newest first.
///
/// A plain list on purpose. It answers one question — "where did my coins
/// go?" — and each row says what happened, when, by how much, and what that
/// left.
class NewCoinsHistoryPage extends StatefulWidget {
  const NewCoinsHistoryPage({super.key});

  @override
  State<NewCoinsHistoryPage> createState() => _NewCoinsHistoryPageState();
}

class _NewCoinsHistoryPageState extends State<NewCoinsHistoryPage> {
  final NewCoinsRepository _repo = getIt<NewCoinsRepository>();
  final ScrollController _scroll = ScrollController();

  final List<NewCoinTransaction> _items = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _loadMore();
    }
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
    return Scaffold(
      backgroundColor: c.pageBg,
      appBar: BaseAppBar(title: 'new_coins_history'.tr()),
      body: _items.isEmpty ? _placeholder() : _list(),
    );
  }

  Widget _placeholder() {
    final c = context.colors;
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _failed
                  ? 'book_network_error'.tr()
                  : 'new_coins_history_empty'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular14.copyWith(color: c.textSecondary),
            ),
            if (_failed) ...[
              12.kh,
              TextButton(
                onPressed: _loadMore,
                child: Text(
                  'retry'.tr(),
                  style:
                      AppText.medium14.copyWith(color: AppColors.brandPurple),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _list() {
    final c = context.colors;
    return ListView.separated(
      controller: _scroll,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, __) => Divider(height: 1, color: c.border),
      itemBuilder: (context, i) {
        if (i >= _items.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child: _failed
                  ? TextButton(
                      onPressed: _loadMore,
                      child: Text(
                        'retry'.tr(),
                        style: AppText.medium14
                            .copyWith(color: AppColors.brandPurple),
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          );
        }
        return _TransactionRow(tx: _items[i]);
      },
    );
  }
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
