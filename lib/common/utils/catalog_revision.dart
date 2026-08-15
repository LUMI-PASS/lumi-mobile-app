import 'package:flutter/foundation.dart';

/// Bumped whenever a purchase changes what the catalog should say about itself.
///
/// A course card is priced PER VIEWER: the server answers "first lesson free",
/// then "next lesson 20 000", then the whole-course price once the trials are
/// used up (see `CourseCardPriceKind`). Buying a trial therefore changes the
/// price on every card for that course — including the ones already rendered on
/// the home feed and in search.
///
/// Nothing else notices that. Home only reloads on a language or coupon change,
/// so a buyer came back from a successful purchase to cards still offering the
/// lesson they had just bought. Screens that show course prices watch this and
/// refetch when it moves.
final ValueNotifier<int> catalogRevision = ValueNotifier<int>(0);

/// Call after any purchase that completed — free, card, or gateway.
void markCatalogChanged() => catalogRevision.value++;
