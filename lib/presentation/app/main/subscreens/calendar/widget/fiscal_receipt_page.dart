import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
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
    final primary = context.colors.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: const Color(0xFF1E293B), size: 20.w),
          onPressed: () => context.router.maybePop(),
        ),
        centerTitle: true,
        title: 'fiscal_receipt'.tr().s(15).w(700).c(const Color(0xFF1E293B)),
        actions: [
          if (_error != 'unavailable')
            IconButton(
              tooltip: 'fiscal_receipt_open_browser'.tr(),
              icon: Icon(Icons.open_in_new_rounded,
                  color: primary, size: 20.w),
              onPressed: _openInBrowser,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _buildBody(primary),
      ),
    );
  }

  Widget _buildBody(Color primary) {
    if (_error == 'unavailable') {
      return _ReceiptMessage(
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF94A3B8),
        title: 'fiscal_receipt_unavailable'.tr(),
        actionLabel: 'booking_retry'.tr(),
        onAction: _resolve,
      );
    }

    if (_error == 'load') {
      return _ReceiptMessage(
        icon: Icons.cloud_off_rounded,
        color: const Color(0xFFEF4444),
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
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(color: primary, strokeWidth: 2.5),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReceiptMessage extends StatelessWidget {
  const _ReceiptMessage({
    required this.icon,
    required this.color,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 34.w),
            ),
            18.kh,
            title.s(16).w(700).c(const Color(0xFF1E293B)),
            24.kh,
            SizedBox(
              width: double.infinity,
              child: Material(
                color: primary,
                borderRadius: BorderRadius.circular(16.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: onAction,
                  child: Container(
                    height: 52.h,
                    alignment: Alignment.center,
                    child: actionLabel.s(15).w(700).c(Colors.white),
                  ),
                ),
              ),
            ),
            if (secondaryLabel != null && onSecondary != null) ...[
              10.kh,
              TextButton(
                onPressed: onSecondary,
                child: secondaryLabel!.s(14).w(600).c(const Color(0xFF64748B)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
