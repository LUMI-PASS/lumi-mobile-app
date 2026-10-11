import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_shadows.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/detail/detail_card.dart';
import 'package:lumi_pass/common/widget/expandable_description.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/common/widget/location_preview_map.dart';
import 'package:lumi_pass/common/widget/map_route_sheet.dart';
import 'package:lumi_pass/common/widget/stretchy_hero.dart';
import 'package:lumi_pass/data/api_model/unclaimed_centre/unclaimed_centre.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_unclaimed_shelf.dart';
import 'package:url_launcher/url_launcher.dart';

const double _kHeroHeight = 300;
const double _kMapHeight = 140;

/// A centre Lumi listed from open sources, before the centre signed.
///
/// The branch page's sibling, and deliberately not the branch page: that one
/// ends in a list of classes to book, and there is nothing to book here. This
/// one is a profile to read — what the place is, what it offers, where it is,
/// when it is open — that ends in a phone number.
///
/// It says, once and near the top, that the centre has not confirmed any of
/// it. A parent who phones and finds the hours wrong should have been told.
///
/// Opened with the card's [centre], so the photo and the name are on screen
/// at once; everything the card does not carry arrives with the request.
@RoutePage()
class UnclaimedCentrePage extends StatefulWidget {
  const UnclaimedCentrePage({super.key, required this.centre});

  final UnclaimedCentre centre;

  @override
  State<UnclaimedCentrePage> createState() => _UnclaimedCentrePageState();
}

class _UnclaimedCentrePageState extends State<UnclaimedCentrePage> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  /// 0 → hero fully visible, 1 → the frosted scrim is fully on. A notifier,
  /// not page state, for the reason spelled out on the branch page: it moves
  /// every scroll frame and only the scrim should rebuild.
  final ValueNotifier<double> _topScrim = ValueNotifier<double>(0);
  final ValueNotifier<bool> _scrimTookOver = ValueNotifier<bool>(false);

  late UnclaimedCentre _centre = widget.centre;
  bool _loading = true;
  bool _failed = false;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _topScrim.dispose();
    _scrimTookOver.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final full =
          await getIt<HomeRepository>().getUnclaimedCentre(widget.centre.id);
      if (!mounted) return;
      setState(() {
        _centre = full;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _onScroll() {
    final start = _kHeroHeight.h * 0.45;
    final end = _kHeroHeight.h * 0.85;
    final t =
        ((_scrollController.offset - start) / (end - start)).clamp(0.0, 1.0);
    _topScrim.value = t;
    _scrimTookOver.value = t > 0.5;
  }

  bool get _hasMap => isUsableCoords(_centre.latitude, _centre.longitude);

  void _openRoute() {
    if (!_hasMap) return;
    MapRouteSheet.show(
      context,
      lat: _centre.latitude!,
      lng: _centre.longitude!,
      title: _centre.name,
      subtitle: _centre.address,
    );
  }

  /// Silent on failure, like the class page's call row: a device with no
  /// dialler is not worth a snackbar.
  Future<void> _call(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return;
    await launchUrl(Uri.parse('tel:$digits'));
  }

  Future<void> _open(String link) async {
    final uri = Uri.tryParse(link.startsWith('http') ? link : 'https://$link');
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final safeTop = MediaQuery.of(context).viewPadding.top;
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;
    final phones = _centre.phones;

    return ValueListenableBuilder<bool>(
      valueListenable: _scrimTookOver,
      builder: (_, tookOver, child) {
        final darkIcons = !c.isDark && tookOver;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                darkIcons ? Brightness.dark : Brightness.light,
            statusBarBrightness:
                darkIcons ? Brightness.light : Brightness.dark,
          ),
          child: child!,
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _hero(c, safeTop)),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _identityCard(c),
                      if (_centre.activities.isNotEmpty) ...[
                        12.verticalSpace,
                        _activitiesCard(c),
                      ],
                      12.verticalSpace,
                      _locationCard(c),
                      if (_hoursLines().isNotEmpty) ...[
                        12.verticalSpace,
                        _hoursCard(c),
                      ],
                      if (_hasExtras) ...[
                        12.verticalSpace,
                        _extrasCard(c),
                      ],
                      if (phones.isNotEmpty || _centre.socials.isNotEmpty) ...[
                        12.verticalSpace,
                        _contactsCard(c),
                      ],
                      if (_loading)
                        Padding(
                          padding: EdgeInsets.only(top: 24.h),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.brandPurple,
                          ),
                        ),
                      if (_failed)
                        Padding(
                          padding: EdgeInsets.only(top: 16.h),
                          child: TextButton(
                            onPressed: _load,
                            child: Text(
                              'unclaimed_retry'.tr(),
                              style: AppText.medium14
                                  .copyWith(color: AppColors.brandPurple),
                            ),
                          ),
                        ),
                      // Room for the call button, when there is one.
                      SizedBox(
                        height: 24.h +
                            safeBottom +
                            (phones.isNotEmpty ? 72.h : 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: ValueListenableBuilder<double>(
                  valueListenable: _topScrim,
                  builder: (_, t, __) => DetailTopScrim(
                    color: c.scaffoldBg,
                    height: safeTop + 56.h,
                    t: t,
                  ),
                ),
              ),
            ),
            Positioned(
              top: safeTop + 8.h,
              left: 16.w,
              child: DetailControlButton(
                onTap: () => context.router.pop(),
                child: HomeIcon(Assets.icons.home.arrow,
                    size: 16, color: c.textPrimary),
              ),
            ),
            // The one thing to DO here. Pinned, because the number is the
            // point of the page and it sits at the very bottom of it.
            if (phones.isNotEmpty)
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: safeBottom + 12.h,
                child: GradientButton(
                  text: 'unclaimed_call'.tr(),
                  onPressed: () => _call(phones.first),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Hero ──────────────────────────────────────────────────────────────────
  Widget _hero(AppColorScheme c, double safeTop) {
    final images = _centre.gallery
        .map(sanitizeImageUrl)
        .whereType<String>()
        .toList();
    return StretchyHero(
      controller: _scrollController,
      height: _kHeroHeight.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _imageIndex = i),
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: images[i],
                fit: BoxFit.cover,
                placeholder: (_, __) => ColoredBox(color: c.control),
                errorWidget: (_, __, ___) => ColoredBox(color: c.control),
              ),
            )
          else
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.indigo),
            ),
          // A soft dark fade so the back control reads on a bright photo.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: safeTop + 72.h,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.28),
                      Colors.black.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 12.h,
              right: 16.w,
              child: FrostedCard(
                hasBorder: false,
                boxShadow: AppShadows.control,
                borderRadius: BorderRadius.circular(32.r),
                child: Text(
                  '${_imageIndex + 1} / ${images.length}',
                  style: AppText.medium12.copyWith(color: c.textPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Who it is ─────────────────────────────────────────────────────────────
  Widget _identityCard(AppColorScheme c) {
    final logo = sanitizeImageUrl(_centre.logo);
    final kind = unclaimedKindLabel(_centre.centreKind);
    final under = [kind, if (_centre.district != null) _centre.district!]
        .join(' · ');
    final facts = _facts();

    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (logo != null) ...[
                Container(
                  width: 52.w,
                  height: 52.w,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.controlBorder),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: logo,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                12.horizontalSpace,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _centre.name,
                      style: AppText.heading20.copyWith(color: c.textPrimary),
                    ),
                    4.verticalSpace,
                    Text(
                      under,
                      style:
                          AppText.regular14.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (facts.isNotEmpty) ...[
            14.verticalSpace,
            Row(
              children: [
                for (final (i, fact) in facts.indexed) ...[
                  if (i > 0) 8.horizontalSpace,
                  Expanded(child: _FactTile(c: c, fact: fact)),
                ],
              ],
            ),
          ],
          if (_centre.description.isNotEmpty) ...[
            18.verticalSpace,
            ExpandableDescription(
              header: DetailCardHeader(
                c: c,
                icon: Assets.icons.detail.iconsaxQuestionMark,
                iconGradient: AppGradients.brand,
                title: 'branch_about'.tr(),
              ),
              text: _centre.description,
              textAlign: TextAlign.justify,
            ),
          ],
        ],
      ),
    );
  }

  /// Up to three figures worth a tile: age, the centre's own starting price,
  /// and how long it has been open. Each only when the source had it.
  List<({String label, String value})> _facts() {
    final from = _centre.ageFrom;
    final to = _centre.ageTo;
    final price = _centre.priceFrom;
    final year = _centre.foundedYear;
    return [
      if (from != null || to != null)
        (
          label: 'unclaimed_age'.tr(),
          value: from != null && to != null
              ? '$from–$to'
              : from != null
                  ? '$from+'
                  : '0–$to',
        ),
      if (price != null && price > 0)
        (
          label: switch (_centre.period) {
            UnclaimedPricePeriod.year => 'unclaimed_price_year'.tr(),
            UnclaimedPricePeriod.visit => 'unclaimed_price_visit'.tr(),
            UnclaimedPricePeriod.month => 'unclaimed_price_month'.tr(),
            // A price with no stated period: the unit alone.
            UnclaimedPricePeriod.unknown => uzsCurrencyLabel(),
          },
          value: price.toGrouped(),
        ),
      if (year != null) (label: 'unclaimed_since'.tr(), value: '$year'),
    ];
  }

  // ─── What it offers ────────────────────────────────────────────────────────
  Widget _activitiesCard(AppColorScheme c) {
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.home.book,
            iconGradient: AppGradients.indigo,
            title: 'unclaimed_activities'.tr(),
          ),
          12.verticalSpace,
          _chips(c, _centre.activities.map((a) => a.name).toList()),
        ],
      ),
    );
  }

  Widget _chips(AppColorScheme c, List<String> labels) => Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [
          for (final label in labels)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: c.control,
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Text(
                label,
                style: AppText.medium13.copyWith(color: c.textPrimary),
              ),
            ),
        ],
      );

  // ─── Where it is ───────────────────────────────────────────────────────────
  Widget _locationCard(AppColorScheme c) {
    final address = _centre.address;
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.detail.icLocation,
            iconGradient: AppGradients.brand,
            title: 'branch_address'.tr(),
          ),
          12.verticalSpace,
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _hasMap ? _openRoute : null,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    address.isEmpty ? 'branch_no_address'.tr() : address,
                    style: AppText.medium14.copyWith(color: c.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          if (_hasMap) ...[
            12.verticalSpace,
            LocationPreviewMap(
              lat: _centre.latitude!,
              lng: _centre.longitude!,
              title: _centre.name,
              subtitle: address.isEmpty ? null : address,
              height: _kMapHeight.h,
            ),
          ],
        ],
      ),
    );
  }

  // ─── When it is open ───────────────────────────────────────────────────────
  /// The week as lines, neighbouring days with the same hours folded into one
  /// ("Du–Ju · 09:00–18:00"). Falls back to the source's own wording when it
  /// gave no structured hours.
  List<({String days, String hours})> _hoursLines() {
    final week = [..._centre.workHours.where((h) => h.weekday > 0)]
      ..sort((a, b) => a.weekday.compareTo(b.weekday));
    if (week.isEmpty) {
      final text = _centre.hoursText;
      return text == null ? const [] : [(days: '', hours: text)];
    }
    String short(int weekday) => 'weekday_short_$weekday'.tr();
    final lines = <({String days, String hours})>[];
    var first = week.first;
    var last = week.first;
    void flush() => lines.add((
          days: first.weekday == last.weekday
              ? short(first.weekday)
              : '${short(first.weekday)}–${short(last.weekday)}',
          hours: '${first.start}–${first.end}',
        ));
    for (final day in week.skip(1)) {
      final continues = day.weekday == last.weekday + 1 &&
          day.start == first.start &&
          day.end == first.end;
      if (!continues) {
        flush();
        first = day;
      }
      last = day;
    }
    flush();
    return lines;
  }

  Widget _hoursCard(AppColorScheme c) {
    final lines = _hoursLines();
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.home.clock,
            iconGradient: AppGradients.green,
            title: 'unclaimed_hours'.tr(),
          ),
          12.verticalSpace,
          for (final (i, line) in lines.indexed) ...[
            if (i > 0) 8.verticalSpace,
            Row(
              children: [
                if (line.days.isNotEmpty)
                  Expanded(
                    child: Text(
                      line.days,
                      style:
                          AppText.regular14.copyWith(color: c.textSecondary),
                    ),
                  ),
                Flexible(
                  flex: line.days.isEmpty ? 1 : 0,
                  child: Text(
                    line.hours,
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── The rest of what the source knew ──────────────────────────────────────
  bool get _hasExtras =>
      _centre.facilities.isNotEmpty ||
      _centre.languages.isNotEmpty ||
      _centre.studiedLanguages.isNotEmpty ||
      _centre.programmes.isNotEmpty;

  Widget _extrasCard(AppColorScheme c) {
    final groups = [
      (title: 'unclaimed_facilities'.tr(), items: _centre.facilities),
      (title: 'unclaimed_languages'.tr(), items: _centre.languages),
      (
        title: 'unclaimed_studied_languages'.tr(),
        items: _centre.studiedLanguages,
      ),
      (title: 'unclaimed_programmes'.tr(), items: _centre.programmes),
    ].where((group) => group.items.isNotEmpty).toList();

    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, group) in groups.indexed) ...[
            if (i > 0) 16.verticalSpace,
            Text(
              group.title,
              style: AppText.semibold14.copyWith(color: c.textPrimary),
            ),
            10.verticalSpace,
            _chips(c, group.items),
          ],
        ],
      ),
    );
  }

  /// The network's own mark, in the brand purple the phone row uses.
  Widget _socialIcon(String key) {
    final svg = switch (key) {
      'instagram' => Assets.icons.social.instagram,
      'telegram' => Assets.icons.telegram,
      'facebook' => Assets.icons.social.facebook,
      'youtube' => Assets.icons.social.youtube,
      'tiktok' => Assets.icons.social.tiktok,
      _ => null,
    };
    if (svg == null) {
      return Icon(Icons.language_rounded,
          size: 18.w, color: AppColors.brandPurple);
    }
    return HomeIcon(svg, size: 18, color: AppColors.brandPurple);
  }

  // ─── How to reach it ───────────────────────────────────────────────────────
  Widget _contactsCard(AppColorScheme c) {
    const order = [
      'instagram',
      'telegram',
      'website',
      'facebook',
      'youtube',
      'tiktok',
    ];
    final socials = [
      for (final key in order)
        if (_centre.socials[key] != null) (key, _centre.socials[key]!),
    ];
    final rows = <Widget>[
      for (final phone in _centre.phones)
        _ContactRow(
          c: c,
          icon: Icon(Icons.call_rounded,
              size: 18.w, color: AppColors.brandPurple),
          label: phone,
          onTap: () => _call(phone),
        ),
      for (final (key, link) in socials)
        _ContactRow(
          c: c,
          icon: _socialIcon(key),
          label: key == 'website'
              ? link.replaceFirst(RegExp(r'^https?://(www\.)?'), '')
              : '${key[0].toUpperCase()}${key.substring(1)}',
          onTap: () => _open(link),
        ),
    ];
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.home.users,
            iconGradient: AppGradients.indigo,
            title: 'unclaimed_contacts'.tr(),
          ),
          12.verticalSpace,
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) 8.verticalSpace,
            row,
          ],
        ],
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({required this.c, required this.fact});

  final AppColorScheme c;
  final ({String label, String value}) fact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              fact.value,
              maxLines: 1,
              style: AppText.semibold16.copyWith(color: c.textPrimary),
            ),
          ),
          2.verticalSpace,
          Text(
            fact.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.regular12.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.c,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final AppColorScheme c;
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
        decoration: BoxDecoration(
          color: c.control,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: c.surface, shape: BoxShape.circle),
              child: icon,
            ),
            10.horizontalSpace,
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.semibold14.copyWith(color: c.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
