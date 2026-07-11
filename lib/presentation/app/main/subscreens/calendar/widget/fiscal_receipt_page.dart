import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/control_chip.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Full-page view of the official OFD/Soliq fiscal receipt for a paid order.
/// Renders the Payme `fiscal_data.qr_code_url` (an ofd.soliq.uz check page)
/// inside an in-app WebView. Pushed from the booking detail screen on mobile;
/// on web the booking detail opens the URL in a new tab instead.
@RoutePage()
class FiscalReceiptPage extends StatefulWidget {
  const FiscalReceiptPage({super.key, required this.orderId, this.initialUrl});

  final String orderId;

  /// Receipt URL already known from the order-detail payload. When null/empty
  /// the page fetches it on demand via [OrdersApi.getOrderReceipt].
  final String? initialUrl;

  @override
  State<FiscalReceiptPage> createState() => _FiscalReceiptPageState();
}

class _FiscalReceiptPageState extends State<FiscalReceiptPage> {
  WebViewController? _controller;
  String? _url;

  /// True while the webview is still painting the receipt page.
  bool _pageLoading = true;

  /// True while we're still resolving which URL to load.
  bool _resolving = true;

  /// 'unavailable' (no receipt yet) | 'load' (webview failed) | null (ok).
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    setState(() {
      _resolving = true;
      _pageLoading = true;
      _error = null;
    });

    var url = widget.initialUrl;
    if (url == null || url.isEmpty) {
      try {
        url = await getIt<OrdersApi>().getOrderReceipt(widget.orderId);
      } catch (_) {/* treat as unavailable below */}
    }
    if (!mounted) return;

    if (url == null || url.isEmpty) {
      setState(() {
        _resolving = false;
        _pageLoading = false;
        _error = 'unavailable';
      });
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Stays white in both themes: the page inside is ofd.soliq.uz's own
      // white document, and a dark backdrop behind it would only show as a
      // flash before it paints.
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _pageLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _pageLoading = false);
          },
          onWebResourceError: (error) {
            // Sub-resource errors fire often and harmlessly; only surface a
            // hard failure of the main document.
            if (error.isForMainFrame == false) return;
            if (mounted) {
              setState(() {
                _pageLoading = false;
                _error = 'load';
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    setState(() {
      _url = url;
      _controller = controller;
      _resolving = false;
    });
  }

  Future<void> _openInBrowser() async {
    final url = _url ?? widget.initialUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(
        title: 'fiscal_receipt'.tr(),
        actions: [
          if (_error != 'unavailable')
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: ControlChip(
                onTap: _openInBrowser,
                width: 36.w,
                height: 36.w,
                padding: EdgeInsets.zero,
                borderWidth: 1.5,
                child: HomeIcon(Assets.icons.detail.share,
                    size: 16, color: c.textPrimary),
              ),
            ),
        ],
      ),
      body: SafeArea(top: false, child: _body(c)),
    );
  }

  Widget _body(AppColorScheme c) {
    if (_error == 'unavailable') {
      return _ReceiptMessage(
        c: c,
        icon: Assets.icons.detail.iconsaxReceipt,
        color: c.textMuted,
        title: 'fiscal_receipt_unavailable'.tr(),
        actionLabel: 'booking_retry'.tr(),
        onAction: _resolve,
      );
    }

    if (_error == 'load') {
      return _ReceiptMessage(
        c: c,
        icon: Assets.icons.notification.close,
        color: AppColors.error,
        title: 'fiscal_receipt_error'.tr(),
        actionLabel: 'fiscal_receipt_open_browser'.tr(),
        onAction: _openInBrowser,
        secondaryLabel: 'booking_retry'.tr(),
        onSecondary: _resolve,
      );
    }

    return Stack(
      children: [
        if (_controller != null)
          Positioned.fill(child: WebViewWidget(controller: _controller!)),
        if (_resolving || _pageLoading)
          Positioned.fill(
            child: ColoredBox(
              color: c.surface,
              child: Center(
                child: CircularProgressIndicator(
                  color: c.primary,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReceiptMessage extends StatelessWidget {
  const _ReceiptMessage({
    required this.c,
    required this.icon,
    required this.color,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final AppColorScheme c;
  final SvgGenImage icon;
  final Color color;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final secondary = secondaryLabel;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: HomeIcon(icon, size: 32, color: color),
            ),
            18.verticalSpace,
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.semibold16.copyWith(color: c.textPrimary),
            ),
            24.verticalSpace,
            GradientButton(text: actionLabel, onPressed: onAction),
            if (secondary != null && onSecondary != null) ...[
              10.verticalSpace,
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSecondary,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    secondary,
                    style:
                        AppText.medium14.copyWith(color: c.textSecondary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
