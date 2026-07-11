import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';

/// The parent's avatar, as a path on this device.
///
/// There is no parent-photo endpoint yet, so the picked file is persisted in
/// [Storage.avatarPath] and broadcast here — same pattern as
/// `displayNameNotifier`, so every screen showing the avatar re-renders without
/// a refetch. When the upload API lands, this becomes a URL and the write below
/// becomes an upload.
final parentAvatarNotifier = ValueNotifier<String?>(null);

/// Seeds the notifier from disk. Safe to call repeatedly.
void loadParentAvatar() {
  parentAvatarNotifier.value ??= getIt<Storage>().avatarPath.call();
}

Future<void> setParentAvatar(File photo) async {
  await getIt<Storage>().avatarPath.set(photo.path);
  parentAvatarNotifier.value = photo.path;
}

/// The stored file, or null when nothing was picked (or the file is gone —
/// iOS clears the picker cache between builds).
File? parentAvatarFile() {
  // Falls back to disk so a cold start paints the avatar without anyone having
  // to seed the notifier first.
  final path = parentAvatarNotifier.value ?? getIt<Storage>().avatarPath.call();
  if (path == null) return null;
  final file = File(path);
  return file.existsSync() ? file : null;
}
