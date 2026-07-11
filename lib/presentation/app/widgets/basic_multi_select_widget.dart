import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BasicMultiSelectDropdown<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String hintText;
  final String Function(T) displayText;
  final String Function(T)? getItemId;
  final VoidCallback? onFirstClick;
  final bool isLoading;
  final Function(List<T>) onSelectionChanged;
  final Widget Function(T)? selectedItemBuilder;
  final EdgeInsetsGeometry? padding;
  final TextStyle? hintStyle;
  final TextStyle? selectedItemStyle;
  final Color? selectedItemBackgroundColor;
  final Color? selectedItemTextColor;
  final BorderRadius? selectedItemBorderRadius;
  final double selectedItemSpacing;
  final double selectedItemRunSpacing;
  final double? maxDropdownHeight;
  final bool closeOnSelection;
  final String? loadingText;
  final String? emptyStateText;
  final String? allSelectedText;

  const BasicMultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.hintText,
    required this.displayText,
    required this.onSelectionChanged,
    this.getItemId,
    this.onFirstClick,
    this.isLoading = false,
    this.selectedItemBuilder,
    this.padding,
    this.hintStyle,
    this.selectedItemStyle,
    this.selectedItemBackgroundColor,
    this.selectedItemTextColor,
    this.selectedItemBorderRadius,
    this.selectedItemSpacing = 8.0,
    this.selectedItemRunSpacing = 8.0,
    this.maxDropdownHeight = 300.0,
    this.closeOnSelection = true,
    this.loadingText,
    this.emptyStateText,
    this.allSelectedText,
  });

  @override
  State<BasicMultiSelectDropdown<T>> createState() =>
      _BasicMultiSelectDropdownState<T>();
}

class _BasicMultiSelectDropdownState<T>
    extends State<BasicMultiSelectDropdown<T>> {
  bool _isDropdownOpen = false;
  bool _hasClickedOnce = false;
  bool _isFirstClickLoading = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _dropdownKey = GlobalKey();

  @override
  void didUpdateWidget(BasicMultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Stop first click loading when items are loaded
    if (_isFirstClickLoading && widget.items.isNotEmpty) {
      setState(() {
        _isFirstClickLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            key: _dropdownKey,
            height: 50.h,
            padding: widget.padding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                width: _isDropdownOpen ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.white,
            ),
            child: InkWell(
              onTap: _handleDropdownTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: widget.hintText.s(14).w(400).c(Colors.grey.shade600),
                  ),
                  if (_isFirstClickLoading) ...[
                    SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ] else ...[
                    AnimatedRotation(
                      turns: _isDropdownOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: _isDropdownOpen
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade600,
                        size: 20.w,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Selected items display
        if (widget.selectedItems.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Wrap(
            spacing: widget.selectedItemSpacing,
            runSpacing: widget.selectedItemRunSpacing,
            children: widget.selectedItems.map((item) {
              return widget.selectedItemBuilder?.call(item) ??
                  _buildDefaultSelectedItem(item);
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDefaultSelectedItem(T item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _removeItem(item),
        borderRadius:
        widget.selectedItemBorderRadius ?? BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCAD9E2)),
            color:
            widget.selectedItemBackgroundColor ?? const Color(0xFFF6F7FB),
            borderRadius:
            widget.selectedItemBorderRadius ?? BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: widget.displayText(item).s(12).w(400).c(
                  widget.selectedItemTextColor ?? const Color(0xFF8E99A1),
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.close,
                size: 14.w,
                color: widget.selectedItemTextColor ?? Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDropdownTap() async {
    // Handle first click loading
    if (!_hasClickedOnce && widget.onFirstClick != null) {
      setState(() {
        _hasClickedOnce = true;
        _isFirstClickLoading = true;
      });

      // Call the onFirstClick callback
      widget.onFirstClick!();

      // Wait for items to be populated with timeout
      await _waitForItems();

      if (mounted) {
        setState(() {
          _isFirstClickLoading = false;
        });
      }
    }
    if (!_isFirstClickLoading) {
      if (_isDropdownOpen) {
        _removeOverlay();
      } else {
        _showOverlay();
      }
    }
  }

  Future<void> _waitForItems() async {
    int attempts = 0;
    const maxAttempts = 50;

    while (attempts < maxAttempts && widget.items.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;

      if (widget.items.isNotEmpty) {
        break;
      }
    }
  }

  void _showOverlay() {
    setState(() {
      _isDropdownOpen = true;
    });

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  // Calculate optimal position for dropdown
  ({bool showAbove, double adjustedHeight}) _calculateDropdownPosition() {
    final renderBox = _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return (showAbove: false, adjustedHeight: widget.maxDropdownHeight ?? 300.h);

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = widget.maxDropdownHeight ?? 300.h;

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

  OverlayEntry _createOverlayEntry() {
    final renderBox = _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;
    final position = _calculateDropdownPosition();

    // Debug print to see what's happening
    print('Dropdown position: showAbove=${position.showAbove}, height=${position.adjustedHeight}');

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: position.showAbove
              ? Offset(0, -position.adjustedHeight - 8.h) // Show above with gap
              : Offset(0, size.height + 8.h), // Show below with gap
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              height: position.adjustedHeight, // Use fixed height instead of maxHeight
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.white,
              ),
              child: _buildDropdownContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContent() {
    final availableItems = _getAvailableItems();

    // Show empty state when no items are available
    if (availableItems.isEmpty) {
      String emptyMessage;
      if (widget.items.isEmpty) {
        emptyMessage = widget.emptyStateText ?? Strings.notFound;
      } else {
        emptyMessage = widget.allSelectedText ?? 'All items selected';
      }

      return Container(
        height: 80.h,
        child: Center(
          child: emptyMessage.s(14).w(400).c(Colors.grey.shade600),
        ),
      );
    }

    // Show items list
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: availableItems.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
      itemBuilder: (context, index) {
        final item = availableItems[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectItem(item),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: widget.displayText(item).s(14).w(400).c(
                      context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectItem(T item) {
    final newSelectedItems = List<T>.from(widget.selectedItems)..add(item);
    widget.onSelectionChanged(newSelectedItems);

    if (widget.closeOnSelection) {
      _removeOverlay();
    }
  }

  void _removeItem(T item) {
    final newSelectedItems = List<T>.from(widget.selectedItems);

    if (widget.getItemId != null) {
      newSelectedItems.removeWhere(
            (selectedItem) =>
        widget.getItemId!(selectedItem) == widget.getItemId!(item),
      );
    } else {
      newSelectedItems.remove(item);
    }

    widget.onSelectionChanged(newSelectedItems);
  }

  List<T> _getAvailableItems() {
    if (widget.getItemId != null) {
      final selectedIds = widget.selectedItems.map(widget.getItemId!).toSet();
      return widget.items
          .where((item) => !selectedIds.contains(widget.getItemId!(item)))
          .toList();
    } else {
      return widget.items
          .where((item) => !widget.selectedItems.contains(item))
          .toList();
    }
  }
}

/*
Usage Example:

BasicMultiSelectDropdown<LoadType>(
  items: widget.state.loadTypesModel ?? [],
  selectedItems: selectedLoadTypes,
  hintText: "Select load types",
  displayText: (type) => type.name ?? "",
  getItemId: (type) => type.id?.toString(),
  onFirstClick: () => widget.addPostCubit.getAllLoadTypes(),
  isLoading: widget.state.isLoading,
  onSelectionChanged: (selectedItems) {
    setState(() {
      selectedLoadTypes = selectedItems;
    });
  },
  selectedItemBackgroundColor: Colors.blue.shade100,
  selectedItemTextColor: Colors.blue.shade800,
  selectedItemBorderRadius: BorderRadius.circular(16),
  maxDropdownHeight: 250,
  closeOnSelection: false, // Keep dropdown open for multiple selections
  loadingText: "Loading options...",
  emptyStateText: "No options available",
  allSelectedText: "All options selected",
)
*/