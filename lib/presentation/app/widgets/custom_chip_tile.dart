import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';

class CustomChipTile extends StatefulWidget {
  const CustomChipTile(
      {super.key, required this.onTap, required this.title, this.icon, this.height, required this.state});

  final Function(bool) onTap;
  final Widget? icon;
  final String title;
  final double? height;
  final bool state;

  @override
  State<CustomChipTile> createState() => _CustomChipTileState();
}

class _CustomChipTileState extends State<CustomChipTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap(!widget.state);
      },
      child: Container(
        height: widget.height ?? 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFCAD9E2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (widget.icon != null) widget.icon!,
            8.kw,
            Expanded(child: widget.title.s(13).w(400).c(const Color(0xFF8E99A1)).m(1).o(TextOverflow.ellipsis)),
            Checkbox(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: widget.state,
              onChanged: (value) {
                widget.onTap(value!);
              },
              activeColor: context.colors.greenHeadline,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
              side: BorderSide(color: context.colors.grey, width: 1.5.w),
              checkColor: context.colors.onPrimary,
            )
          ],
        ),
      ),
    );
  }
}
