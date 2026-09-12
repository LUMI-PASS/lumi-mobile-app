import 'package:flutter_test/flutter_test.dart';

/// The dedupe rule `DeeplinkService` applies, isolated.
///
/// The service itself needs a router and the AppsFlyer/app_links plugins, so
/// the decision is pinned here rather than by driving the whole service. What
/// matters is the rule: the SAME link inside the window is one event, a
/// different link is not, and the same link later is not.
bool isDuplicate({
  required String incoming,
  required String? lastLink,
  required Duration? since,
  Duration window = const Duration(seconds: 3),
}) {
  if (lastLink != incoming) return false;
  if (since == null) return false;
  return since < window;
}

void main() {
  group('a link delivered twice', () {
    test('the second delivery is dropped', () {
      // AppsFlyer's UDL callback and app_links both hand us the same URI,
      // milliseconds apart. Without this, the destination is pushed twice and
      // auto_route keys both entries identically.
      expect(
        isDuplicate(
          incoming: 'lumi://plans',
          lastLink: 'lumi://plans',
          since: const Duration(milliseconds: 40),
        ),
        isTrue,
      );
    });

    test('a different link is never dropped', () {
      expect(
        isDuplicate(
          incoming: 'lumi://coupons',
          lastLink: 'lumi://plans',
          since: const Duration(milliseconds: 40),
        ),
        isFalse,
      );
    });

    test('the same link with a different id is a different link', () {
      expect(
        isDuplicate(
          incoming: 'lumi://class/b',
          lastLink: 'lumi://class/a',
          since: const Duration(milliseconds: 40),
        ),
        isFalse,
      );
    });

    test('re-opening the same link later still works', () {
      expect(
        isDuplicate(
          incoming: 'lumi://plans',
          lastLink: 'lumi://plans',
          since: const Duration(seconds: 10),
        ),
        isFalse,
      );
    });

    test('the first link of the session is never a duplicate', () {
      expect(
        isDuplicate(incoming: 'lumi://plans', lastLink: null, since: null),
        isFalse,
      );
    });
  });
}
