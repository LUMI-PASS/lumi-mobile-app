import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/common_text_filed.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';

@RoutePage()
class SearchUnifiedPage extends StatefulWidget {
  const SearchUnifiedPage({
    super.key,
    this.initialCategory,
  });

  final String? initialCategory;

  @override
  State<SearchUnifiedPage> createState() => _SearchUnifiedPageState();
}

class _SearchUnifiedPageState extends State<SearchUnifiedPage> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;
  int _tab = 0;
  final int _filterCount = 4;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  static const _trendItems = [
    "Bahor ta'til playgroundlar",
    '3D modellashtirish',
    'Bepul tadbirlar',
    'Trampolin park',
  ];

  static const _segmentLabels = ['Hammasi', 'Playground', 'Masterclass', 'Tadbir'];

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF6C4EF2);
    final isSearchEmpty = _searchCtrl.text.trim().isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFAF5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Text(
                'Qidiruv',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0E0C2B),
                  letterSpacing: -0.3,
                ),
              ),
            ),
            12.kh,
            // Search bar + filter
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFE8E4F6)),
                      ),
                      child: CommonTextField(
                        controller: _searchCtrl,
                        prefixIcon: Assets.icons.search.svg(),
                        hint: "Search",
                        onChanged: (t) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  10.kw,
                  _FilterWithBadge(
                    count: _filterCount,
                    onTap: () {
                      FilterBottomSheet.show(context);
                    },
                  ),
                ],
              ),
            ),
            12.kh,
            // Segment pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: List.generate(_segmentLabels.length, (i) {
                  final selected = _tab == i;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF6C4EF2)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF6C4EF2)
                                : const Color(0xFFE8E4F6),
                          ),
                        ),
                        child: Text(
                          _segmentLabels[i],
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF6B6899),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            12.kh,
            // Trend section — shown only when search is empty
            if (isSearchEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'Trend',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1535),
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              8.kh,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _trendItems.map((item) {
                    return GestureDetector(
                      onTap: () {
                        _searchCtrl.text = item;
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE8FF),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up_rounded,
                                size: 14.sp,
                                color: const Color(0xFF6C4EF2)),
                            6.kw,
                            Text(
                              item,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4A2FD4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              12.kh,
            ],
            // Selected category chip
            if (_selectedCategory != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _TagChip(
                    text: _selectedCategory!,
                    onClear: () => setState(() => _selectedCategory = null),
                  ),
                ),
              ),
              12.kh,
            ],
            // Results count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '6 ta natija topildi',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B6899),
                ),
              ),
            ),
            8.kh,
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                physics: kIsWeb ? const ClampingScrollPhysics() : const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: 6,
                separatorBuilder: (_, __) => 16.kh,
                itemBuilder: (_, i) {
                  final isCategoryMode = _selectedCategory != null;
                  final title = isCategoryMode
                      ? (_tab == 0 ? "Chess class" : "Chess center")
                      : (i == 0 ? "Creative Party Muse" : "Design workshop");

                  final metaTop = isCategoryMode
                      ? "Education, Music  •  15-17 y.o"
                      : "Education, Music  •  15-17 y.o";

                  const location = "Ko'kcha st, 69 (1.9 km)";
                  final price = (10 + i).toString();

                  return _SearchResultCard(
                    primary: primary,
                    title: title,
                    metaTop: metaTop,
                    location: location,
                    price: price,
                    image: Assets.images.defaultImage.path,
                    showDateRow: isCategoryMode && _tab == 1 && i.isOdd,
                    onTap: () {
                      if (_selectedCategory == null) {
                        setState(() => _selectedCategory = "Education");
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterWithBadge extends StatelessWidget {
  const _FilterWithBadge({required this.count, this.onTap});
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: primary,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Assets.icons.filter.svg(color: Colors.white),
            ),
          ),
        ),
        Positioned(
          right: -6,
          top: -6,
          child: CircleAvatar(
            radius: 11,
            backgroundColor: Colors.white,
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text, this.onClear});
  final String text;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              text.s(12).w(600).c(context.colors.primary),
              6.kw,
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 16, color: context.colors.primary),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedButton extends StatelessWidget {
  const _SegmentedButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      height: 44,
      decoration: BoxDecoration(
        color: selected ? primary : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? primary : Theme.of(context).dividerColor,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.primary,
    required this.title,
    required this.metaTop,
    required this.location,
    required this.price,
    required this.image,
    this.showDateRow = false,
    this.onTap,
  });

  final Color primary;
  final String title;
  final String metaTop;
  final String location;
  final String price;
  final String image;
  final bool showDateRow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              10.kh,
              if (showDateRow) ...[
                Row(
                  children: [
                    "Sep 29, 2022".s(11).w(500).c(Colors.black54),
                    8.kw,
                    "•".s(11).w(700).c(Colors.black26),
                    8.kw,
                    "10:00 PM".s(11).w(500).c(Colors.black54),
                  ],
                ),
                8.kh,
              ],
              metaTop.s(11).w(500).c(Colors.black54),
              6.kh,
              title.s(16).w(700),
              12.kh,
              Row(
                children: [
                  Assets.icons.location.svg(
                    width: 15.w,
                    height: 15.h,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF9CA3AF),
                      BlendMode.srcIn,
                    ),
                  ),
                  6.kw,
                  Expanded(
                    child: location.s(12).w(500).c(Colors.black54),
                  ),
                  6.kw,
                  _CoinPill(primary: primary, text: price),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill({required this.primary, required this.text});
  final Color primary;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5FF),
        borderRadius: BorderRadius.circular(8),
        // boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8)],
      ),
      child: Row(
        children: [
          text.s(12).w(700),
          6.kw,
          Assets.icons.coinLumi.image(width: 18.w, height: 18.h),
        ],
      ),
    );
  }
}
