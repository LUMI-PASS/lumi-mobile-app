import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Only the hidden "Район" section uses it — restore with that section.
// import 'package:lumi_pass/common/constants/districts.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';
import 'package:lumi_pass/common/widget/date_range_picker_sheet.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/category_picker_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/location_filter_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/time_filter.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

enum DatePreset { none, today, tomorrow, thisWeek, custom }

enum Gender { any, boy, girl }

enum PricePreset { any, custom }

/// What kind of thing the results list should hold.
///
/// Activities and courses share one grid — they answer the same question, "what
/// is on for my child" — so narrowing is a FILTER here next to age and price,
/// not a separate screen.
///
/// No plain "activities only" option, because nobody shops that way — a
/// parent looks for what is on. The sheet offers everything or [coins] (what
/// the parent's Lumi Coin pack buys); [courses] is shown only while Home's
/// "Все курсы" has it on.
enum ActivityKind {
  /// Both. The default, and what the screen opens on.
  any,

  /// Courses alone. What Home's "see all courses" arrives with.
  courses,

  /// Only what a Lumi Coin pack buys — one-time, priced activities of a
  /// partner whose plan sells them. What Home's "Входит в подписку" arrives
  /// with; the server narrows the centres and the map the same way.
  coins;

  /// The `kind` query param. [any] sends `all` explicitly, because the
  /// endpoint's own default — what an older client gets by sending nothing —
  /// is activities only, and this screen wants both.
  String get queryValue => switch (this) {
        ActivityKind.courses => 'courses',
        ActivityKind.coins => 'coins',
        ActivityKind.any => 'all',
      };

  String get label => switch (this) {
        ActivityKind.courses => 'filter_kind_courses'.tr(),
        ActivityKind.coins => 'included_in_subscription'.tr(),
        ActivityKind.any => 'filter_kind_all'.tr(),
      };
}

class FilterResult {
  final DatePreset datePreset;
  final DateTime? fromDate;
  final DateTime? toDate;

  /// Activities, courses, or both. Both by default — see [ActivityKind].
  final ActivityKind kind;

  /// Lower bound of the age range (the "от" field).
  final int? ageYears;

  /// Upper bound of the age range (the "до" field).
  final int? ageToYears;
  final Gender gender;
  final PricePreset pricePreset;
  final RangeValues priceRange;

  /// Tashkent district slugs the buyer ticked. Empty = anywhere; the backend
  /// takes them as a comma-separated `districts` query param.
  final Set<String> districts;

  /// The categories the buyer ticked in the sheet's grid. Empty = every
  /// category.
  ///
  /// The resolved objects rather than bare ids, because that is the shape
  /// `SearchCubit.selectedCategories` keeps — the removable chips above the
  /// results read a title off each one, and an id cannot supply it.
  ///
  /// Carried on the filter so one Apply commits the whole sheet. The map
  /// screen keeps its own dedicated category picker and simply never passes a
  /// category list in, which leaves its grid section unbuilt and this empty.
  final List<HomCategory> categories;

  /// "By time": the window a lesson has to START in, as minutes past midnight.
  /// The whole day ([dayStart]–[dayEnd]) is no filter — see [hasTime].
  final int fromMinute;
  final int toMinute;

  /// "By location": only centres within this many km of ([nearLat],
  /// [nearLng]) — the user's position when the radius was picked. Null = any
  /// distance. Set from the map's location chip only; the sheet carries it
  /// through untouched.
  final double? radiusKm;
  final double? nearLat;
  final double? nearLng;

  const FilterResult({
    this.datePreset = DatePreset.none,
    this.fromDate,
    this.toDate,
    this.kind = ActivityKind.any,
    this.ageYears,
    this.ageToYears,
    this.gender = Gender.any,
    this.pricePreset = PricePreset.any,
    this.priceRange = const RangeValues(minPrice, maxPrice),
    this.districts = const {},
    this.categories = const [],
    this.fromMinute = dayStart,
    this.toMinute = dayEnd,
    this.radiusKm,
    this.nearLat,
    this.nearLng,
  });

  static const double minPrice = 10000;
  static const double maxPrice = 400000;

  static const int dayStart = 0;
  static const int dayEnd = 23 * 60 + 59;

  bool get hasTime => fromMinute > dayStart || toMinute < dayEnd;

  bool get hasRadius => radiusKm != null && nearLat != null && nearLng != null;

  /// The radius dropped — "All" on the location screen. A separate method
  /// because [copyWith] reads null as "keep".
  FilterResult withoutRadius() => FilterResult(
        datePreset: datePreset,
        fromDate: fromDate,
        toDate: toDate,
        kind: kind,
        ageYears: ageYears,
        ageToYears: ageToYears,
        gender: gender,
        pricePreset: pricePreset,
        priceRange: priceRange,
        districts: districts,
        categories: categories,
        fromMinute: fromMinute,
        toMinute: toMinute,
      );

  // Keep backward compat
  DateTime? get customDate => fromDate;

  FilterResult copyWith({
    DatePreset? datePreset,
    DateTime? fromDate,
    DateTime? toDate,
    ActivityKind? kind,
    int? ageYears,
    int? ageToYears,
    Gender? gender,
    PricePreset? pricePreset,
    RangeValues? priceRange,
    Set<String>? districts,
    List<HomCategory>? categories,
    int? fromMinute,
    int? toMinute,
    double? radiusKm,
    double? nearLat,
    double? nearLng,
  }) {
    return FilterResult(
      datePreset: datePreset ?? this.datePreset,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      kind: kind ?? this.kind,
      ageYears: ageYears ?? this.ageYears,
      ageToYears: ageToYears ?? this.ageToYears,
      gender: gender ?? this.gender,
      pricePreset: pricePreset ?? this.pricePreset,
      priceRange: priceRange ?? this.priceRange,
      districts: districts ?? this.districts,
      categories: categories ?? this.categories,
      fromMinute: fromMinute ?? this.fromMinute,
      toMinute: toMinute ?? this.toMinute,
      radiusKm: radiusKm ?? this.radiusKm,
      nearLat: nearLat ?? this.nearLat,
      nearLng: nearLng ?? this.nearLng,
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final FilterResult? initial;

  /// Every category there is to offer. The "Категории" row is built only when
  /// there is something to offer — this, or a category already picked. The
  /// map and the list both pass it, so the sheet is the same on either.
  final List<HomCategory> categories;

  /// Centres to dot the radius page's map with — whatever the caller has
  /// loaded. Only a preview: the page works the same with none.
  final List<HomBranch> branches;

  const FilterBottomSheet({
    super.key,
    this.initial,
    this.categories = const [],
    this.branches = const [],
  });

  static Future<FilterResult?> show(
    BuildContext context, {
    FilterResult? initial,
    List<HomCategory> categories = const [],
    List<HomBranch> branches = const [],
  }) {
    return showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface,
      barrierColor: AppColors.ink.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => FilterBottomSheet(
        initial: initial,
        categories: categories,
        branches: branches,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late DatePreset _datePreset;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _ageFromController = TextEditingController();
  final TextEditingController _ageToController = TextEditingController();
  Gender _gender = Gender.any;
  ActivityKind _kind = ActivityKind.any;
  Set<String> _districts = <String>{};
  RangeValues _range =
      const RangeValues(FilterResult.minPrice, FilterResult.maxPrice);
  DayWindow _time = DayWindow.all;

  /// "По расположению" — the same radius the map's location chip sets, so a
  /// distance picked on either view is on both. Null = any distance; the
  /// centre is where it was measured from.
  double? _radiusKm;
  double? _nearLat;
  double? _nearLng;

  /// The ticked categories, by id. Ids rather than objects so a tick survives
  /// the catalogue being re-fetched underneath the sheet.
  Set<String> _categoryIds = <String>{};

  /// Every category this sheet can hand back, by id: the ones on offer PLUS
  /// the ones that arrived already ticked.
  ///
  /// The second half matters. Search can open filtered by a category tapped on
  /// Home while its own full category list is still in flight, so a pick can
  /// be live without being in [FilterBottomSheet.categories] — and resolving
  /// the result against that list alone would quietly drop it on Apply.
  late final Map<String, HomCategory> _knownCategories = {
    for (final cat in [
      ...widget.categories,
      ...?widget.initial?.categories,
    ])
      if (cat.id != null) cat.id!: cat,
  };

  /// What the grid draws: the catalogue, with any already-ticked category that
  /// is missing from it appended, so a live pick is always visible and
  /// untickable-by-accident.
  List<HomCategory> get _offeredCategories {
    final offered = [
      for (final cat in widget.categories)
        if ((cat.title ?? '').isNotEmpty) cat,
    ];
    final have = offered.map((c) => c.id).toSet();
    for (final cat in widget.initial?.categories ?? const <HomCategory>[]) {
      if ((cat.title ?? '').isNotEmpty && !have.contains(cat.id)) {
        offered.add(cat);
      }
    }
    return offered;
  }

  /// Mirrors the age fields' emptiness so [_onAgeTyped] can tell when the Clear
  /// button's enabled state actually needs a rebuild.
  bool _ageFieldsEmpty = true;

  @override
  void initState() {
    super.initState();
    final init = widget.initial ?? const FilterResult();
    _datePreset = init.datePreset;
    _fromDate = init.fromDate;
    _toDate = init.toDate;
    _gender = init.gender;
    _kind = init.kind;
    _districts = {...init.districts};
    _categoryIds = {
      for (final cat in init.categories)
        if (cat.id != null) cat.id!,
    };
    _range = init.priceRange;
    _time = DayWindow(init.fromMinute, init.toMinute);
    if (init.hasRadius) {
      _radiusKm = init.radiusKm;
      _nearLat = init.nearLat;
      _nearLng = init.nearLng;
    }
    if (init.ageYears != null) _ageFromController.text = '${init.ageYears}';
    if (init.ageToYears != null) _ageToController.text = '${init.ageToYears}';
    _ageFieldsEmpty = _ageFieldsAreEmpty;
    _ageFromController.addListener(_onAgeTyped);
    _ageToController.addListener(_onAgeTyped);
  }

  @override
  void dispose() {
    _ageFromController.removeListener(_onAgeTyped);
    _ageToController.removeListener(_onAgeTyped);
    _ageFromController.dispose();
    _ageToController.dispose();
    super.dispose();
  }

  bool get _ageFieldsAreEmpty =>
      _ageFromController.text.isEmpty && _ageToController.text.isEmpty;

  /// Typing in a `TextField` doesn't rebuild the sheet, so the Clear button
  /// would stay greyed out after an age is entered. Only the empty↔filled flip
  /// matters here, so this rebuilds on that and not on every keystroke.
  void _onAgeTyped() {
    if (_ageFieldsAreEmpty != _ageFieldsEmpty) {
      setState(() => _ageFieldsEmpty = _ageFieldsAreEmpty);
    }
  }

  int? _parseAge(TextEditingController controller) {
    final value = int.tryParse(controller.text.trim());
    if (value == null || value < 1 || value > 16) return null;
    return value;
  }

  bool get _isPriceChanged =>
      _range.start != FilterResult.minPrice ||
      _range.end != FilterResult.maxPrice;

  /// Whether anything is set — drives the Clear button's enabled look, so it
  /// never invites a tap that would do nothing.
  bool get _hasAnyFilter =>
      _datePreset != DatePreset.none ||
      _fromDate != null ||
      _toDate != null ||
      !_ageFieldsAreEmpty ||
      _gender != Gender.any ||
      _kind != ActivityKind.any ||
      _districts.isNotEmpty ||
      _categoryIds.isNotEmpty ||
      !_time.isAll ||
      _radiusKm != null ||
      _isPriceChanged;

  /// Resets every control back to its default. Stays in the sheet on purpose:
  /// the buyer sees the chips deselect and the sliders spring back, then
  /// commits with Apply — same two-step as changing any other filter.
  void _clearAll() {
    // Outside setState: clearing a controller notifies its listeners straight
    // away, and [_onAgeTyped] sets state of its own.
    _ageFromController.clear();
    _ageToController.clear();
    setState(() {
      _datePreset = DatePreset.none;
      _fromDate = null;
      _toDate = null;
      _gender = Gender.any;
      _kind = ActivityKind.any;
      _districts = <String>{};
      _categoryIds = <String>{};
      _range = const RangeValues(FilterResult.minPrice, FilterResult.maxPrice);
      _time = DayWindow.all;
      _radiusKm = null;
      _nearLat = null;
      _nearLng = null;
    });
  }

  FilterResult _buildResult() => FilterResult(
        datePreset: _datePreset,
        fromDate: _fromDate,
        toDate: _toDate,
        ageYears: _parseAge(_ageFromController),
        ageToYears: _parseAge(_ageToController),
        gender: _gender,
        kind: _kind,
        pricePreset: _isPriceChanged ? PricePreset.custom : PricePreset.any,
        priceRange: _range,
        districts: _districts,
        // Resolved through [_knownCategories] rather than filtered out of the
        // offered list, so a pick made before the catalogue landed survives.
        categories: [
          for (final id in _categoryIds)
            if (_knownCategories[id] != null) _knownCategories[id]!,
        ],
        fromMinute: _time.from,
        toMinute: _time.to,
        radiusKm: _radiusKm,
        nearLat: _nearLat,
        nearLng: _nearLng,
      );

  /// What the "Категории" row says: "Выбрать" with nothing ticked, the one title
  /// with a single pick, and the first title plus "+N" with several — the
  /// map's category chip says it the same way.
  String get _categoryLabel {
    final picked = [
      for (final id in _categoryIds)
        if ((_knownCategories[id]?.title ?? '').isNotEmpty)
          _knownCategories[id]!.title!,
    ];
    if (picked.isEmpty) return 'select'.tr();
    if (picked.length == 1) return picked.first;
    return '${picked.first} +${picked.length - 1}';
  }

  /// The categories page, over this sheet. Its pick replaces the ticks here
  /// and is committed with everything else on Apply.
  Future<void> _pickCategories() async {
    final result = await CategoryPickerPage.show(
      context,
      categories: _offeredCategories,
      selected: [
        for (final id in _categoryIds)
          if (_knownCategories[id] != null) _knownCategories[id]!,
      ],
    );
    if (result == null || !mounted) return;
    setState(() {
      _categoryIds = {
        for (final cat in result.categories)
          if (cat.id != null) cat.id!,
      };
    });
  }

  /// The map's own radius page, over this sheet. Measured from the centre
  /// already in use when there is a radius, so widening it does not move it.
  Future<void> _pickRadius() async {
    final centre = _radiusKm != null
        ? Point(latitude: _nearLat!, longitude: _nearLng!)
        : await radiusCentre();
    if (!mounted) return;
    final result = await LocationFilterPage.show(
      context,
      center: centre,
      branches: widget.branches,
      initialRadiusKm: _radiusKm,
    );
    if (result == null || !mounted) return;
    setState(() {
      _radiusKm = result.radiusKm;
      _nearLat = result.radiusKm == null ? null : centre.latitude;
      _nearLng = result.radiusKm == null ? null : centre.longitude;
    });
  }

  void _selectDatePreset(DatePreset preset) {
    setState(() {
      _datePreset = preset;
      _fromDate = null;
      _toDate = null;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await AppDateRangePickerSheet.show(
      context,
      initial: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );
    if (picked == null) return;
    setState(() {
      _datePreset = DatePreset.custom;
      _fromDate = picked.start;
      _toDate = picked.end;
    });
  }

  String get _calendarChipLabel {
    if (_datePreset != DatePreset.custom || _fromDate == null) {
      return 'filter_choose_calendar'.tr();
    }
    final from = _fmtDate(_fromDate!);
    return _toDate == null ? from : '$from – ${_fmtDate(_toDate!)}';
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.kh,
          Container(
            width: 32.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: c.textSecondary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          12.kh,
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'filter_title'.tr(),
                      textAlign: TextAlign.center,
                      style: AppText.heading20.copyWith(color: c.textPrimary),
                    ),
                  ),
                  8.kh,
                  // "Тип": everything, or only what a Lumi Coin pack buys —
                  // what Home's "Входит в подписку" opens on, so the filter it
                  // set is visible here and can be lifted. No "Курсы" pill:
                  // the app is not selling courses now. A courses filter
                  // that arrives from Home's "Все курсы" still shows, so it is
                  // never on without being seen.
                  _Section(
                    label: 'filter_kind'.tr(),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        for (final kind in [
                          ActivityKind.any,
                          ActivityKind.coins,
                          if (_kind == ActivityKind.courses)
                            ActivityKind.courses,
                        ])
                          FilterPill(
                            label: kind.label,
                            selected: _kind == kind,
                            onTap: () => setState(() => _kind = kind),
                          ),
                      ],
                    ),
                  ),
                  16.kh,
                  _Section(
                    label: 'filter_date'.tr(),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        FilterPill(
                          label: 'today'.tr(),
                          selected: _datePreset == DatePreset.today,
                          onTap: () => _selectDatePreset(DatePreset.today),
                        ),
                        FilterPill(
                          label: 'tomorrow'.tr(),
                          selected: _datePreset == DatePreset.tomorrow,
                          onTap: () => _selectDatePreset(DatePreset.tomorrow),
                        ),
                        FilterPill(
                          label: 'this_week'.tr(),
                          selected: _datePreset == DatePreset.thisWeek,
                          onTap: () => _selectDatePreset(DatePreset.thisWeek),
                        ),
                        FilterPill(
                          label: _calendarChipLabel,
                          selected: _datePreset == DatePreset.custom,
                          onTap: _pickDateRange,
                        ),
                      ],
                    ),
                  ),
                  16.kh,
                  _Section(
                    label: 'filter_class_time'.tr(),
                    child: TimeRangeField(
                      value: _time,
                      onChanged: (v) => setState(() => _time = v),
                    ),
                  ),
                  16.kh,
                  _Section(
                    label: 'age'.tr(),
                    child: Row(
                      children: [
                        Expanded(
                          child: _AgeField(
                            controller: _ageFromController,
                            hint: 'age_from'.tr(),
                          ),
                        ),
                        8.kw,
                        Expanded(
                          child: _AgeField(
                            controller: _ageToController,
                            hint: 'age_to'.tr(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.kh,
                  // "Район" is hidden for now: "По расположению" at the bottom
                  // picks a radius around the user, which answers the same
                  // question.
                  // The district filter itself still works — a value already
                  // set is kept and Clear removes it — so this can come back
                  // by uncommenting it.
                  // _Section(
                  //   label: 'filter_district'.tr(),
                  //   child: Wrap(
                  //     spacing: 8.w,
                  //     runSpacing: 8.h,
                  //     children: [
                  //       for (final d in kTashkentDistricts)
                  //         FilterPill(
                  //           label: d.label,
                  //           selected: _districts.contains(d.key),
                  //           // Multi-select: each chip toggles on its own, so a
                  //           // parent can pick the two districts they'd actually
                  //           // travel to. No chip selected = anywhere.
                  //           onTap: () => setState(() {
                  //             if (!_districts.remove(d.key)) {
                  //               _districts.add(d.key);
                  //             }
                  //           }),
                  //         ),
                  //     ],
                  //   ),
                  // ),
                  // 16.kh,
                  16.kh,
                  _Section(
                    label: 'gender'.tr(),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        FilterPill(
                          label: 'gender_all'.tr(),
                          selected: _gender == Gender.any,
                          onTap: () => setState(() => _gender = Gender.any),
                        ),
                        FilterPill(
                          label: 'filter_for_boys'.tr(),
                          selected: _gender == Gender.boy,
                          onTap: () => setState(() => _gender = Gender.boy),
                        ),
                        FilterPill(
                          label: 'filter_for_girls'.tr(),
                          selected: _gender == Gender.girl,
                          onTap: () => setState(() => _gender = Gender.girl),
                        ),
                      ],
                    ),
                  ),
                  16.kh,
                  _Section(
                    label: 'price_label'.tr(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fmtPrice(_range.start),
                              style: AppText.semibold12
                                  .copyWith(color: c.textPrimary),
                            ),
                            Text(
                              _fmtPrice(_range.end),
                              style: AppText.semibold12
                                  .copyWith(color: c.textPrimary),
                            ),
                          ],
                        ),
                        6.kh,
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 6.h,
                            activeTrackColor: c.primary,
                            inactiveTrackColor: c.progressTrack,
                            overlayColor: c.primary.withValues(alpha: 0.12),
                            rangeThumbShape: FilterRangeThumb(color: c.primary),
                            rangeTrackShape:
                                const RoundedRectRangeSliderTrackShape(),
                            showValueIndicator: ShowValueIndicator.never,
                          ),
                          child: RangeSlider(
                            min: FilterResult.minPrice,
                            max: FilterResult.maxPrice,
                            values: _range,
                            onChanged: (v) => setState(() => _range = v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // The two filters with a page of their own come last, as
                  // one-line rows — "Категории … Выбрать ›" — the way 1fit
                  // closes its sheet. Each opens its full-screen page, and
                  // what is picked there is committed with the rest on Apply.
                  if (_offeredCategories.isNotEmpty)
                    _PickerRow(
                      title: 'categories'.tr(),
                      value:
                          _categoryIds.isEmpty ? 'select'.tr() : _categoryLabel,
                      onTap: _pickCategories,
                    ),
                  _PickerRow(
                    title: 'map_by_location'.tr(),
                    value: _radiusKm == null
                        ? 'select'.tr()
                        : radiusLabel(_radiusKm!),
                    onTap: _pickRadius,
                  ),
                  16.kh,
                ],
              ),
            ),
          ),
          Padding(
            // `useSafeArea` on a modal sheet only guards the top, so the home
            // indicator has to be paid for here.
            padding: EdgeInsets.fromLTRB(
              14.w,
              4.h,
              14.w,
              16.h + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilterSheetButton(
                    label: 'clear_button'.tr(),
                    enabled: _hasAnyFilter,
                    onTap: _clearAll,
                  ),
                ),
                8.kw,
                Expanded(
                  child: FilterSheetButton(
                    label: 'apply_button'.tr(),
                    gradient: AppGradients.brand,
                    onTap: () => Navigator.of(context).pop(_buildResult()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtPrice(double value) {
    final grouped = value.toInt().toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => ' ',
        );
    return '$grouped ${'uzs_currency'.tr()}';
  }
}

/// Section label + its content, the 8px-gap block the sheet repeats.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.medium14.copyWith(color: context.colors.textPrimary),
        ),
        8.kh,
        child,
      ],
    );
  }
}

/// A filter that has a page of its own — "Категории", "По расположению" — as
/// one line: the filter's name on the left, what is picked (or "Выбрать") on
/// the right, and a "›" to the page that changes it.
class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.controlBorder)),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: AppText.medium16.copyWith(color: c.textPrimary),
            ),
            12.kw,
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.medium14.copyWith(color: c.primary),
              ),
            ),
            4.kw,
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: c.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill chip — indigo gradient when selected, flat control fill otherwise.
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textColor = selected ? AppColors.onBrand : c.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? null : c.control,
          gradient: selected ? AppGradients.indigo : null,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child:
            Text(label, style: AppText.semibold12.copyWith(color: textColor)),
      ),
    );
  }
}

/// One of the two age bounds — a 40h field with a trailing "лет" suffix.
class _AgeField extends StatelessWidget {
  const _AgeField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              style: AppText.regular12.copyWith(color: c.textPrimary),
              cursorColor: c.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: hint,
                hintStyle: AppText.regular12.copyWith(color: c.textMuted),
                border: InputBorder.none,
              ),
            ),
          ),
          8.kw,
          Text(
            'age_years_suffix'.tr(),
            style: AppText.regular12.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Pill action button sized like the app's primary [GradientButton] (50h /
/// 44r) — [gradient] makes it the primary one.
class FilterSheetButton extends StatelessWidget {
  const FilterSheetButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;

  /// Greyed out and inert — used by Clear when there is nothing to clear.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // IgnorePointer rather than a null `onTap`: Bouncing always dereferences
    // its callback after the bounce, so a disabled button has to stop the tap
    // before it gets there.
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Bouncing(
          onTap: onTap,
          child: Container(
            height: 50.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: gradient == null ? c.control : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(44.r),
            ),
            child: Text(
              label,
              style: AppText.medium16.copyWith(
                color: gradient == null ? c.textPrimary : AppColors.onBrand,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Flat 20px round thumb — a filled brand dot with a thin light ring.
class FilterRangeThumb extends RangeSliderThumbShape {
  const FilterRangeThumb({required this.color});

  final Color color;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(20, 20);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = true,
    bool isOnTop = false,
    bool isPressed = false,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, 10, Paint()..color = color);
    canvas.drawCircle(
      center,
      9,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.onBrand.withValues(alpha: 0.35),
    );
  }
}
