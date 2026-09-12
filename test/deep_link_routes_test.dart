import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/router/deep_link_routes.dart';

/// The registry's job is to make three link shapes mean the same screen:
/// a `lumi://` scheme link, an https share link on one of our hosts, and the
/// `?id=` form a hand-written link is likely to use. These pin that down,
/// because the failure mode is silent — a banner that opens nothing.
void main() {
  DeepLinkTarget? resolve(String link) =>
      DeepLinkRoutes.resolve(Uri.parse(link));

  group('scheme links', () {
    test('reads the destination from the host and the id from the path', () {
      final t = resolve('lumi://class/abc123');
      expect(t?.key, 'class');
      expect(t?.id, 'abc123');
    });

    test('a destination with no id resolves with no id', () {
      final t = resolve('lumi://plans');
      expect(t?.key, 'plans');
      expect(t?.id, isNull);
    });

    test('takes the id from ?id= when the path has none', () {
      expect(resolve('lumi://class?id=abc123')?.id, 'abc123');
    });

    test('keeps extra query parameters', () {
      final t = resolve('lumi://category/cat1?title=Dance');
      expect(t?.id, 'cat1');
      expect(t?.params['title'], 'Dance');
    });

    test('is case-insensitive about the destination', () {
      expect(resolve('lumi://Plans')?.key, 'plans');
    });
  });

  group('app links', () {
    test('a share URL resolves to the same target as the scheme link', () {
      final share = resolve('https://mobile-api.lumipass.uz/share/class/abc123');
      final scheme = resolve('lumi://class/abc123');
      expect(share?.key, scheme?.key);
      expect(share?.id, scheme?.id);
    });

    test('resolves a share URL without the /share/ prefix too', () {
      final t = resolve('https://app.lumipass.uz/branch/b7');
      expect(t?.key, 'branch');
      expect(t?.id, 'b7');
    });

    test('serves every destination, not just class', () {
      expect(resolve('https://mobile-api.lumipass.uz/share/plans')?.key, 'plans');
    });
  });

  group('links that must NOT be handled in-app', () {
    test('a foreign host is left to the browser', () {
      expect(resolve('https://example.com/share/class/abc123'), isNull);
    });

    test('an unregistered destination resolves to nothing', () {
      expect(resolve('lumi://coures/abc123'), isNull);
      expect(resolve('https://mobile-api.lumipass.uz/share/nope/1'), isNull);
    });

    test('our own host with no destination is left to the browser', () {
      expect(resolve('https://lumipass.uz/'), isNull);
    });
  });

  test('every registry key is exposed for the adminka picker', () {
    expect(DeepLinkRoutes.keys, contains('class'));
    expect(DeepLinkRoutes.keys, contains('plans'));
    for (final key in DeepLinkRoutes.keys) {
      expect(DeepLinkRoutes.lookup(key), isNotNull, reason: key);
    }
  });
}
