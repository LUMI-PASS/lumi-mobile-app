import 'dart:math' show Random;

import 'package:lumi_pass/data/storage/storage.dart';

/// A fresh random install id: 16 random bytes as 32 lowercase hex characters.
///
/// [random] is injectable so the shape can be pinned in a test; production
/// always uses [Random.secure].
String generateInstallId([Random? random]) {
  final r = random ?? Random.secure();
  return List.generate(
    16,
    (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

/// This install's id, generated on first use and persisted. See
/// [Storage.installId].
///
/// Shared by every caller that needs a stable per-device signal — banner click
/// dedupe and the referral programme's `X-Device-Id` — so they all report the
/// SAME id rather than each minting its own.
String installIdOf(Storage storage) {
  final existing = storage.installId.call();
  if (existing != null && existing.isNotEmpty) return existing;

  final id = generateInstallId();
  storage.installId.set(id);
  return id;
}
