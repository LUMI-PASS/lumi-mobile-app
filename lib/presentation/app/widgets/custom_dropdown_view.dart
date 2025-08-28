import 'package:flexobo/common/extensions/text_extensions.dart';
import 'package:flexobo/common/extensions/theme_extensions.dart';
import 'package:flexobo/common/gen/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BasicDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?>? onChanged;
  final String Function(T) displayText;
  final String hintText;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final BoxDecoration? decoration;
  final bool isLoading;
  final VoidCallback? onFirstClick;
  final double maxDropdownHeight;
  final bool Function(T, T)? isEqual;

  const BasicDropdown(
      {Key? key,
        required this.items,
        required this.displayText,
        this.selectedItem,
        this.onChanged,
        this.hintText = 'Select an option',
        this.width,
        this.height,
        this.textStyle,
        this.decoration,
        this.isLoading = false,
        this.onFirstClick,
        this.maxDropdownHeight = 200, // Default max height
        this.isEqual})
      : super(key: key);

  @override
  State<BasicDropdown<T>> createState() => _BasicDropdownState<T>();
}

class _BasicDropdownState<T> extends State<BasicDropdown<T>> {
  bool _isExpanded = false;
  bool _hasBeenClicked = false;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      print("overlay removed ::::: \n ::::");
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  // Get the actual width of the dropdown button
  double _getDropdownWidth() {
    final RenderBox? renderBox =
    _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? (widget.width ?? 200);
  }

  // Calculate optimal position for dropdown
  ({bool showAbove, double adjustedHeight}) _calculateDropdownPosition() {
    final renderBox = _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return (showAbove: false, adjustedHeight: widget.maxDropdownHeight);

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = widget.maxDropdownHeight;

    // Calculate available space below and above
    final spaceBelow = screenHeight - position.dy - size.height - 8.h; // Gap below
    final spaceAbove = position.dy - 8.h; // Gap above

    // Minimum height needed for dropdown (at least one item + padding)
    final minHeight = 100.h;

    // Decide whether to show above or below
    bool showAbove = false;
    double adjustedHeight = maxHeight;

    // Always prefer showing above if we're in the bottom half of screen
    // OR if there's not enough space below for minimum height
    if (spaceBelow < minHeight || (position.dy > screenHeight * 0.6 && spaceAbove >= minHeight)) {
      showAbove = true;
      adjustedHeight = spaceAbove.clamp(minHeight, maxHeight);
    } else {
      // Show below and adjust height if needed
      adjustedHeight = spaceBelow.clamp(minHeight, maxHeight);
    }

    return (showAbove: showAbove, adjustedHeight: adjustedHeight);
  }

  void _toggleDropdown() {
    if (!_hasBeenClicked && widget.onFirstClick != null) {
      _hasBeenClicked = true;
      widget.onFirstClick!();

      // Set state first, then create overlay
      setState(() {
        _isExpanded = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _createLoadingOverlay();
        }
      });
      return;
    }
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      // Opening dropdown
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (widget.isLoading) {
            _createLoadingOverlay();
          } else {
            _createOverlay();
          }
        }
      });
    } else {
      // Closing dropdown
      _removeOverlay();
    }
  }

  void _onItemSelected(T item) {
    _removeOverlay();

    // Update state
    setState(() {
      _isExpanded = false;
    });

    // Call callback
    if (widget.onChanged != null) {
      widget.onChanged!(item);
    }

    print("item selected :::: $item");
  }

  void _createLoadingOverlay() {
    _removeOverlay(); // Ensure no duplicate overlays

    final dropdownWidth = _getDropdownWidth();
    final position = _calculateDropdownPosition();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: dropdownWidth,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: position.showAbove
                ? Offset(0, -100 - 8.h) // Show above with gap (100 is loading height)
                : Offset(0, (widget.height ?? 50) + 8.h), // Show below with gap
            child: Material(
              elevation: 8,
              // Increased elevation for better visibility
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              shadowColor: Colors.black26,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _createOverlay() {
    _removeOverlay();

    final itemHeight = 48.h;
    final calculatedHeight =
    (widget.items.length * itemHeight).clamp(0.0, widget.maxDropdownHeight);
    final dropdownWidth = _getDropdownWidth();
    final position = _calculateDropdownPosition();

    // Use the adjusted height from position calculation
    final finalHeight = calculatedHeight.clamp(0.0, position.adjustedHeight);

    // Debug print to see what's happening
    print('Dropdown position: showAbove=${position.showAbove}, height=${position.adjustedHeight}');

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            setState(() {
              _isExpanded = false;
            });
            _removeOverlay();
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              Positioned(
                width: dropdownWidth,
                child: CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: position.showAbove
                      ? Offset(0, -finalHeight - 8.h) // Show above with gap
                      : Offset(0, (widget.height ?? 50) + 8.h), // Show below with gap
                  child: Material(
                    elevation: 8,
                    borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12.r)),
                    color: Colors.white,
                    shadowColor: Colors.black26,
                    child: Container(
                      height: finalHeight, // Use fixed height instead of constraints
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(12.r)),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: widget.items.isEmpty
                          ? SizedBox(
                        height: 50,
                        child: Center(
                          child: Text(
                            Strings.notFound,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF717680),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      )
                          : ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        physics: widget.items.length > 4
                            ? const AlwaysScrollableScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) => Divider(
                            height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          // Use custom equality function if provided
                          final isSelected =
                              widget.selectedItem != null &&
                                  (widget.isEqual != null
                                      ? widget.isEqual!(
                                      widget.selectedItem!, item)
                                      : widget.selectedItem == item);

                          return InkWell(
                            onTap: () => _onItemSelected(item),
                            child: Container(
                              height: itemHeight,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.displayText(item),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? Theme.of(context)
                                            .primaryColor
                                            : const Color(0xFF717680),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      color:
                                      Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void didUpdateWidget(BasicDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle loading state changes more reliably
    if (oldWidget.isLoading != widget.isLoading && _isExpanded) {
      _removeOverlay();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isExpanded) {
          if (widget.isLoading) {
            _createLoadingOverlay();
          } else {
            _createOverlay();
          }
        }
      });
    }

    // Handle items list changes
    if (oldWidget.items != widget.items && _isExpanded && !widget.isLoading) {
      _removeOverlay();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isExpanded) {
          _createOverlay();
        }
      });
    }
  }

  String get _displayValue {
    if (widget.selectedItem != null) {
      return widget.displayText(widget.selectedItem!);
    }
    return widget.hintText;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          key: _dropdownKey,
          // Added key to get actual width
          width: widget.width ?? double.infinity,
          height: widget.height ?? 50.h,
          decoration: widget.decoration ??
              BoxDecoration(
                border: Border.all(
                  color: _isExpanded
                      ? context.colors.primary.withOpacity(0.5)
                      : Colors.grey.shade300,
                  width: _isExpanded ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8.r),
                color: context.colors.grey.withOpacity(0.2),
              ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _displayValue
                    .s(14)
                    .c(widget.selectedItem != null
                    ? Colors.black87
                    : const Color(0xFF717680))
                    .w(400)
                    .m(1)
                    .o(TextOverflow.ellipsis),
              ),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}