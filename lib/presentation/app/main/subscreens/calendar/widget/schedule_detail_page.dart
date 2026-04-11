import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class ScheduleDetailPage extends StatefulWidget {
  final ScheduleItem scheduleItem;

  const ScheduleDetailPage({super.key, required this.scheduleItem});

  @override
  State<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends State<ScheduleDetailPage> {
  List<String> _galleryImages = [];
  bool _isLoadingImages = true;
  bool _isCancelling = false;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  ScheduleItem get item => widget.scheduleItem;
  ScheduleClass? get cls => item.scheduleClass;
  ScheduleChild? get child => item.forChild;

  RelatedBooking? get _booking {
    final bookings = item.relatedBookings ?? [];
    return bookings
            .where((b) => b.bookingStatus?.toUpperCase() == 'CONFIRMED')
            .firstOrNull ??
        bookings.firstOrNull;
  }

  String get _bookingStatus =>
      _booking?.bookingStatus?.toUpperCase() ?? item.status?.toUpperCase() ?? '';

  bool get _isCancelled => _bookingStatus == 'CANCELLED';
  bool get _isConfirmed => _bookingStatus == 'CONFIRMED';
  bool get _isCompleted =>
      _bookingStatus == 'COMPLETED' ||
      _booking?.attendanceStatus?.toUpperCase() == 'ATTENDED';

  @override
  void initState() {
    super.initState();
    _loadImages();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    final classId = cls?.id;
    if (classId == null) {
      setState(() => _isLoadingImages = false);
      return;
    }
    if (cls?.hasPhoto == true) {
      setState(() => _galleryImages = [PhotoService.getImageUrl(classId)]);
    }
    try {
      final photos =
          await PhotoService.instance.getClassPhotos(classId, limit: 5);
      if (mounted && photos.isNotEmpty) {
        setState(() {
          _galleryImages = photos;
          _isLoadingImages = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingImages = false);
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || _galleryImages.length <= 1) return;
      final next = (_currentImageIndex + 1) % _galleryImages.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
      _startAutoSlide();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return '0 min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '$h hour${h > 1 ? 's' : ''}';
    return '$m min';
  }

  String _getGenderText() {
    switch (cls?.gender?.toUpperCase()) {
      case 'MALE': return 'Boys only';
      case 'FEMALE': return 'Girls only';
      default: return 'Everyone';
    }
  }

  Color _getGenderColor() {
    switch (cls?.gender?.toUpperCase()) {
      case 'MALE': return const Color(0xFF3B82F6);
      case 'FEMALE': return const Color(0xFF7C3AED);
      default: return const Color(0xFFA652C7);
    }
  }

  IconData _getGenderIcon() {
    switch (cls?.gender?.toUpperCase()) {
      case 'MALE': return Icons.male_rounded;
      case 'FEMALE': return Icons.female_rounded;
      default: return Icons.people_rounded;
    }
  }

  bool _canCancel() {
    if (!_isConfirmed) return false;
    if (item.forDate == null || item.startTime == null) return true;
    try {
      final start = DateTime.parse('${item.forDate}T${item.startTime}:00');
      return start.difference(DateTime.now()).inHours >= 12;
    } catch (_) {
      return true;
    }
  }

  void _handleCancel() {
    if (item.forDate != null && item.startTime != null) {
      try {
        final start = DateTime.parse('${item.forDate}T${item.startTime}:00');
        if (start.difference(DateTime.now()).inHours < 12) {
          _showTooLateSheet();
          return;
        }
      } catch (_) {}
    }
    _showCancelSheet();
  }

  void _showTooLateSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w, height: 4.h,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            24.kh,
            Container(
              width: 64.w, height: 64.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.schedule_rounded, size: 32.w, color: const Color(0xFFEF4444)),
            ),
            16.kh,
            Text('Too Late', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
            10.kh,
            Text(
              'Cancellation is not available less than 12 hours before the class starts.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500, height: 1.4),
            ),
            24.kh,
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(child: Text('Got it', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white))),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8.h),
          ],
        ),
      ),
    );
  }

  void _showCancelSheet() {
    final reasonController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              24.kh,
              Container(
                width: 64.w, height: 64.w,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cancel_outlined, size: 32.w, color: Colors.red.shade400),
              ),
              16.kh,
              Text('Cancel Class', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
              8.kh,
              Text(
                'Are you sure you want to cancel this booking? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500, height: 1.4),
              ),
              20.kh,
              // Reason input
              Text('Reason (optional)', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
              8.kh,
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tell us why you are cancelling...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: context.colors.primary),
                  ),
                  contentPadding: EdgeInsets.all(14.w),
                ),
              ),
              24.kh,
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text('Keep Booking', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                        ),
                      ),
                    ),
                  ),
                  12.kw,
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await _cancelBooking(reasonController.text.trim());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.red.shade500,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Center(
                          child: Text('Cancel Class', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancelBooking(String reason) async {
    final bookingId = _booking?.id;
    if (bookingId == null) return;
    setState(() => _isCancelling = true);
    try {
      await getIt<HomeRepository>().cancelBooking(bookingId, reason.isEmpty ? 'No reason' : reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class cancelled successfully'), backgroundColor: Colors.green),
        );
        context.router.maybePop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final booking = _booking;
    final chargedAmount = booking?.chargedCoinAmount;
    final isTrial = booking?.isTrialBooking ?? false;

    return Scaffold(
      backgroundColor: context.colors.window,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ─── Hero Image Section (same as class_detail) ───
              SliverToBoxAdapter(
                child: SizedBox(
                  width: 1.sw,
                  height: 300.h,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(28.r),
                            bottomRight: Radius.circular(28.r),
                          ),
                          child: _galleryImages.isNotEmpty
                              ? PageView.builder(
                                  controller: _pageController,
                                  itemCount: _galleryImages.length,
                                  onPageChanged: (i) => setState(() => _currentImageIndex = i),
                                  itemBuilder: (_, i) => CachedNetworkImage(
                                    imageUrl: _galleryImages[i],
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Shimmer.fromColors(
                                      baseColor: Colors.grey.shade200,
                                      highlightColor: Colors.grey.shade50,
                                      child: Container(color: Colors.white),
                                    ),
                                    errorWidget: (_, __, ___) =>
                                        Assets.images.defaultImage.image(fit: BoxFit.cover),
                                  ),
                                )
                              : _isLoadingImages
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey.shade200,
                                      highlightColor: Colors.grey.shade50,
                                      child: Container(color: Colors.white),
                                    )
                                  : Assets.images.defaultImage.image(fit: BoxFit.cover),
                        ),
                      ),
                      // Gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(28.r),
                              bottomRight: Radius.circular(28.r),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.15),
                                Colors.black.withOpacity(0.15),
                                Colors.black.withOpacity(0.55),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Back button
                      Positioned(
                        top: MediaQuery.of(context).viewPadding.top + 10.h,
                        left: 16.w,
                        child: _CircleButton(
                          onTap: () => context.router.maybePop(),
                          child: Icon(Icons.arrow_back_ios_new, color: primary, size: 18.w),
                        ),
                      ),
                      // Status badge
                      Positioned(
                        top: MediaQuery.of(context).viewPadding.top + 14.h,
                        right: 16.w,
                        child: _StatusBadge(status: _bookingStatus),
                      ),
                      // Image indicators
                      if (_galleryImages.length > 1)
                        Positioned(
                          bottom: 60.h,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _galleryImages.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _currentImageIndex == i ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == i
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Title overlay
                      Positioned(
                        bottom: 16.h,
                        left: 20.w,
                        right: 20.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: (cls?.title ?? '').s(20).w(700).c(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Body Content ───
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    16.kh,

                    // Quick info chips
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        // Date
                        _QuickChip(
                          icon: Icons.calendar_today_rounded,
                          label: _formatDate(item.forDate),
                          bgColor: const Color(0xFFEEF2FF),
                          iconColor: const Color(0xFF4338CA),
                          textColor: const Color(0xFF4338CA),
                        ),
                        // Time
                        _QuickChip(
                          icon: Icons.access_time_rounded,
                          label: '${item.startTime ?? ''} - ${item.endTime ?? ''}',
                          bgColor: const Color(0xFFF8FAFC),
                          iconColor: const Color(0xFF475569),
                          textColor: const Color(0xFF475569),
                        ),
                        if (cls?.minAge != null || cls?.maxAge != null)
                          _QuickChip(
                            icon: Icons.child_care_rounded,
                            label: "${cls?.minAge ?? 0}-${cls?.maxAge ?? 0} y.o",
                            bgColor: const Color(0xFFF0FDF4),
                            iconColor: const Color(0xFF16A34A),
                            textColor: const Color(0xFF15803D),
                          ),
                        _QuickChip(
                          icon: _getGenderIcon(),
                          label: _getGenderText(),
                          bgColor: _getGenderColor().withOpacity(0.08),
                          iconColor: _getGenderColor(),
                          textColor: _getGenderColor(),
                        ),
                      ],
                    ),

                    20.kh,

                    // Reserved for (child)
                    if (child != null)
                      _InfoCard(
                        icon: Icons.person_outline_rounded,
                        iconBg: const Color(0xFFEEF2FF),
                        iconColor: const Color(0xFF4338CA),
                        label: 'Reserved for',
                        value: '${child!.firstName ?? ''} ${child!.lastName ?? ''}'.trim(),
                      ),

                    // Charged amount
                    if (chargedAmount != null) ...[
                      12.kh,
                      _InfoCard(
                        icon: Icons.paid_outlined,
                        iconBg: isTrial ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                        iconColor: isTrial ? const Color(0xFF059669) : const Color(0xFFEA580C),
                        label: 'Charged amount',
                        valueWidget: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: isTrial ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  '$chargedAmount'.s(15).w(700).c(
                                      isTrial ? const Color(0xFF059669) : const Color(0xFFEA580C)),
                                  6.kw,
                                  Assets.icons.coinLumi.image(width: 18.w, height: 18.h),
                                ],
                              ),
                            ),
                            8.kw,
                            (isTrial ? 'Trial price' : 'Full price')
                                .s(11)
                                .w(600)
                                .c(isTrial ? const Color(0xFF059669) : const Color(0xFFEA580C)),
                          ],
                        ),
                      ),
                    ],

                    // Location
                    if (cls?.branch != null) ...[
                      12.kh,
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3C539A).withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Icon(Icons.location_on_outlined,
                                  color: const Color(0xFF7C3AED), size: 22.w),
                            ),
                            12.kw,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  'Location'.s(11).w(500).c(const Color(0xFF64748B)),
                                  4.kh,
                                  (cls!.branch!).s(14).w(600).c(const Color(0xFF1E293B)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Duration & Gender cards
                    if (cls?.duration != null) ...[
                      20.kh,
                      Row(
                        children: [
                          Expanded(
                            child: _DetailCard(
                              icon: Icons.timer_outlined,
                              iconBg: const Color(0xFF3B82F6).withOpacity(0.1),
                              iconColor: const Color(0xFF3B82F6),
                              label: 'Duration',
                              value: _formatDuration(cls!.duration),
                            ),
                          ),
                          12.kw,
                          Expanded(
                            child: _DetailCard(
                              icon: _getGenderIcon(),
                              iconBg: _getGenderColor().withOpacity(0.1),
                              iconColor: _getGenderColor(),
                              label: 'Gender & Age',
                              value: _getGenderText(),
                              subtitle: "${cls?.minAge ?? 0}-${cls?.maxAge ?? 0} years old",
                              subtitleColor: _getGenderColor(),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Description
                    if (cls?.description != null && cls!.description!.isNotEmpty) ...[
                      24.kh,
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3C539A).withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36.w,
                                  height: 36.h,
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(Icons.info_outline_rounded, color: primary, size: 18.w),
                                ),
                                10.kw,
                                "About this class".s(16).w(700).c(const Color(0xFF1E293B)),
                              ],
                            ),
                            14.kh,
                            Text(
                              cls!.description!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF4B5563),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    120.kh,
                  ]),
                ),
              ),
            ],
          ),

          // ─── Sticky CTA Button (changes by status) ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                bottom: MediaQuery.of(context).viewPadding.bottom + 16.h,
                top: 20.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.window.withOpacity(0),
                    context.colors.window.withOpacity(0.95),
                    context.colors.window,
                  ],
                  stops: const [0.0, 0.35, 0.6],
                ),
              ),
              child: _buildCtaButton(context, primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context, Color primary) {
    if (_isCancelled) {
      return _CtaButton(
        label: 'Cancelled',
        color: Colors.grey.shade400,
        icon: Icons.cancel_outlined,
        enabled: false,
      );
    }
    if (_isCompleted) {
      return _CtaButton(
        label: 'Completed',
        color: const Color(0xFF16A34A),
        icon: Icons.check_circle_outline,
        enabled: false,
      );
    }
    // CONFIRMED or SCHEDULED - can cancel
    return _CtaButton(
      label: _isCancelling ? 'Cancelling...' : 'Cancel Class',
      color: primary,
      icon: null,
      enabled: !_isCancelling && _canCancel(),
      loading: _isCancelling,
      onTap: _handleCancel,
    );
  }
}

// ─── Reusable widgets (matching class_detail_page style) ───

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          width: 42.w,
          height: 42.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final Color bgColor;
    final String label;
    switch (status) {
      case 'CONFIRMED':
        color = const Color(0xFF16A34A);
        bgColor = Colors.white.withOpacity(0.9);
        label = 'Confirmed';
      case 'CANCELLED':
        color = const Color(0xFFEF4444);
        bgColor = Colors.white.withOpacity(0.9);
        label = 'Cancelled';
      case 'COMPLETED':
        color = const Color(0xFF2563EB);
        bgColor = Colors.white.withOpacity(0.9);
        label = 'Completed';
      default:
        color = const Color(0xFFF59E0B);
        bgColor = Colors.white.withOpacity(0.9);
        label = status.isNotEmpty
            ? '${status[0]}${status.substring(1).toLowerCase()}'
            : 'Scheduled';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8.w, height: 8.w, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          6.kw,
          label.s(12).w(600).c(color),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.icon, required this.label, required this.bgColor, required this.iconColor, required this.textColor});
  final IconData icon;
  final String label;
  final Color bgColor, iconColor, textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.w, color: iconColor),
          6.kw,
          Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.iconBg, required this.iconColor, required this.label, this.value, this.valueWidget});
  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [BoxShadow(color: const Color(0xFF3C539A).withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w, height: 48.h,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14.r)),
            child: Icon(icon, color: iconColor, size: 22.w),
          ),
          12.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label.s(11).w(500).c(const Color(0xFF64748B)),
                4.kh,
                valueWidget ?? (value ?? '').s(14).w(600).c(const Color(0xFF1E293B)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.icon, required this.iconBg, required this.iconColor, required this.label, required this.value, this.subtitle, this.subtitleColor});
  final IconData icon;
  final Color iconBg, iconColor;
  final String label, value;
  final String? subtitle;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [BoxShadow(color: const Color(0xFF3C539A).withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w, height: 40.h,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12.r)),
            child: Icon(icon, color: iconColor, size: 20.w),
          ),
          10.kh,
          label.s(11).w(500).c(const Color(0xFF64748B)),
          4.kh,
          value.s(14).w(700).c(const Color(0xFF1E293B)),
          if (subtitle != null) ...[2.kh, subtitle!.s(12).w(500).c(subtitleColor ?? const Color(0xFF64748B))],
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.label, required this.color, this.icon, this.enabled = true, this.loading = false, this.onTap});
  final String label;
  final Color color;
  final IconData? icon;
  final bool enabled, loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color : color.withOpacity(0.5),
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: enabled
                ? [BoxShadow(color: color.withOpacity(0.34), blurRadius: 26, offset: const Offset(0, 14))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              else ...[
                if (icon != null) ...[Icon(icon, color: Colors.white, size: 20.w), 8.kw],
                label.s(16).w(700).c(Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
