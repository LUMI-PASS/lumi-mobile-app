import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/user_avatar.dart';

/// Avatar + "Добавить фото" from the Figma account/child screens.
///
/// Shows, in order of precedence: the freshly [pickedFile], the [imageUrl]
/// already on the server, or the initials circle. Tapping either the avatar or
/// the caption offers camera/gallery and hands the chosen file to [onPicked] —
/// the caller decides when to upload it.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.onPicked,
    this.pickedFile,
    this.imageUrl,
    this.size = 64,
  });

  final ValueChanged<File> onPicked;

  /// Chosen on this screen but not uploaded yet.
  final File? pickedFile;

  /// The photo the backend already has, if any.
  final String? imageUrl;

  final double size;

  bool get _hasPhoto => pickedFile != null || imageUrl != null;

  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PhotoSourceSheet(),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null) onPicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _pick(context),
          child: UserAvatar(
            file: pickedFile,
            imageUrl: imageUrl,
            size: size,
          ),
        ),
        12.kh,
        GestureDetector(
          onTap: () => _pick(context),
          behavior: HitTestBehavior.opaque,
          child: Text(
            _hasPhoto ? 'change_photo'.tr() : 'add_photo'.tr(),
            style: AppText.semibold14.copyWith(color: colors.link),
          ),
        ),
      ],
    );
  }
}

/// Camera-or-gallery chooser. Pops the picked [ImageSource], or null.
class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        16.h + MediaQuery.of(context).viewPadding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          16.kh,
          _SourceRow(
            icon: Icons.photo_camera_rounded,
            label: 'take_photo'.tr(),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          8.kh,
          _SourceRow(
            icon: Icons.photo_library_rounded,
            label: 'choose_from_gallery'.tr(),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: colors.control,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.w, color: colors.primary),
            12.kw,
            Text(
              label,
              style: AppText.medium14.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
