import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/router/appsflyer_link.dart';
import 'package:lumi_pass/common/router/deep_link_routes.dart';
import 'package:lumi_pass/common/router/referral_link.dart';

/// An invite link is not a destination. Every shape it arrives in must end up
/// as "store this code" — never as a push — while every other deep link keeps
/// routing exactly as before. These pin both halves, because the failure is
/// silent either way: a lost invite, or a screen opened by a friend's code.
void main() {
  LinkIntent classify(String link) => classifyLink(Uri.parse(link));

  /// What `DeeplinkService` does with an AppsFlyer UDL result: the click event
  /// becomes a URI, and the URI is classified.
  LinkIntent fromAppsFlyer(Map<String, dynamic> clickEvent) {
    final uri = appsFlyerClickEventToUri(clickEvent);
    expect(uri, isNotNull, reason: 'click event produced no URI');
    return classifyLink(uri!);
  }

  void expectStores(LinkIntent intent, String code) {
    expect(intent, isA<StoreReferralCode>());
    expect((intent as StoreReferralCode).code, code);
  }

  group('AppsFlyer payload with deep_link_value=referral', () {
    test('direct click: code from deep_link_sub1 is stored, nothing opens', () {
      final intent = fromAppsFlyer({
        'deep_link_value': 'referral',
        'deep_link_sub1': 'LUMI7K3Q',
        'af_sub1': 'LUMI7K3Q',
        'is_deferred': false,
      });
      expectStores(intent, 'LUMI7K3Q');
    });

    test('deferred (first launch after install) is handled the same way', () {
      final intent = fromAppsFlyer({
        'deep_link_value': 'referral',
        'deep_link_sub1': 'LUMI7K3Q',
        'is_deferred': true,
        'media_source': 'user_invite',
      });
      expectStores(intent, 'LUMI7K3Q');
    });

    test('falls back to af_sub1 when deep_link_sub1 is missing', () {
      expectStores(
        fromAppsFlyer({'deep_link_value': 'referral', 'af_sub1': 'lumi7k3q'}),
        'LUMI7K3Q',
      );
    });

    test('the URI it builds is the canonical lumi://referral?code= form', () {
      final uri = appsFlyerClickEventToUri({
        'deep_link_value': 'Referral',
        'deep_link_sub1': ' lumi7k3q ',
      });
      expect(uri.toString(), 'lumi://referral?code=LUMI7K3Q');
    });

    test('a referral payload without a code opens the referral screen', () {
      final intent = fromAppsFlyer({'deep_link_value': 'referral'});
      expect(intent, isA<OpenDestination>());
      expect((intent as OpenDestination).target.key, 'referral');
    });

    test('the raw OneLink in `link` is recognised when nothing else is set',
        () {
      final intent = fromAppsFlyer({
        'link': 'https://link.lumipass.uz/JBWe?deep_link_value=referral'
            '&deep_link_sub1=LUMI7K3Q',
      });
      expectStores(intent, 'LUMI7K3Q');
    });
  });

  group('link shapes', () {
    test('the full OneLink URL the backend emits', () {
      expectStores(
        classify(
          'https://link.lumipass.uz/JBWe?pid=user_invite&c=referral'
          '&deep_link_value=referral&deep_link_sub1=LUMI7K3Q&af_sub1=LUMI7K3Q'
          '&af_web_dp=https%3A%2F%2Fapp.lumipass.uz%2Fr%2FLUMI7K3Q',
        ),
        'LUMI7K3Q',
      );
    });

    test('the raw onelink.me host works like the branded one', () {
      expectStores(
        classify('https://lumipass.onelink.me/JBWe?deep_link_value=referral'
            '&af_sub1=LUMI7K3Q'),
        'LUMI7K3Q',
      );
    });

    test('https://app.lumipass.uz/r/<CODE>', () {
      expectStores(classify('https://app.lumipass.uz/r/LUMI7K3Q'), 'LUMI7K3Q');
    });

    test('lumi://referral?code=<CODE>', () {
      expectStores(classify('lumi://referral?code=LUMI7K3Q'), 'LUMI7K3Q');
    });

    test('lumi://referral/<CODE>', () {
      expectStores(classify('lumi://referral/LUMI7K3Q'), 'LUMI7K3Q');
    });

    test('lumi://referral without a code routes to the referral screen', () {
      final intent = classify('lumi://referral');
      expect(intent, isA<OpenDestination>());
      final target = (intent as OpenDestination).target;
      expect(target.key, 'referral');
      expect(target.id, isNull);
      final entry = DeepLinkRoutes.lookup('referral');
      expect(entry, isNotNull);
      expect(entry!.mode, DeepLinkNavMode.root);
    });

    test('a /r/ link on a foreign host is not ours', () {
      expect(classify('https://example.com/r/LUMI7K3Q'), isA<IgnoreLink>());
      expect(ReferralLinks.parse(Uri.parse('https://example.com/r/X')), isNull);
    });
  });

  group('code normalisation', () {
    test('lowercase and spaces are folded away', () {
      expect(ReferralCodes.normalize(' lumi 7k3q '), 'LUMI7K3Q');
      expect(ReferralCodes.normalize('lumi7k3q\n'), 'LUMI7K3Q');
      expectStores(classify('lumi://referral?code=lumi%207k3q'), 'LUMI7K3Q');
      expectStores(classify('https://app.lumipass.uz/r/lumi7k3q'), 'LUMI7K3Q');
    });

    test('dashes survive (the server normalises them)', () {
      expect(ReferralCodes.normalize('lumi-7k3q'), 'LUMI-7K3Q');
    });

    test('nothing usable is null', () {
      expect(ReferralCodes.normalize(null), isNull);
      expect(ReferralCodes.normalize('   '), isNull);
      expect(ReferralCodes.normalize('<script>'), isNull);
      expect(ReferralCodes.normalize('A' * 40), isNull);
    });

    test('a junk code on a referral link degrades to the referral screen', () {
      final intent = classify('lumi://referral?code=%3C%3E');
      expect(intent, isA<OpenDestination>());
      expect((intent as OpenDestination).target.key, 'referral');
    });
  });

  group('a code that equals a route key is still just a code', () {
    for (final key in ['plans', 'home', 'class', 'wallet', 'referral']) {
      test('"$key"', () {
        expect(DeepLinkRoutes.lookup(key), isNotNull);
        expectStores(classify('lumi://referral?code=$key'), key.toUpperCase());
        expectStores(
          classify('https://app.lumipass.uz/r/$key'),
          key.toUpperCase(),
        );
        expectStores(
          fromAppsFlyer({'deep_link_value': 'referral', 'deep_link_sub1': key}),
          key.toUpperCase(),
        );
      });
    }
  });

  group('every other deep link is unchanged', () {
    test('a registered destination still opens', () {
      final intent = classify('lumi://plans');
      expect(intent, isA<OpenDestination>());
      expect((intent as OpenDestination).target.key, 'plans');
    });

    test('an AppsFlyer class link still resolves to lumi://class/<id>', () {
      final uri = appsFlyerClickEventToUri({
        'deep_link_value': 'class',
        'deep_link_sub1': 'abc123',
      });
      expect(uri.toString(), 'lumi://class/abc123');
      final intent = classifyLink(uri!);
      expect((intent as OpenDestination).target.id, 'abc123');
    });

    test('a whole URI in deep_link_value is passed through', () {
      final uri = appsFlyerClickEventToUri({
        'deep_link_value': 'https://mobile-api.lumipass.uz/share/class/x1',
      });
      expect(uri.toString(), 'https://mobile-api.lumipass.uz/share/class/x1');
    });

    test('an unknown AppsFlyer value with no link yields nothing', () {
      expect(appsFlyerClickEventToUri({'deep_link_value': 'nope'}), isNull);
    });

    test('an unregistered link is ignored, a foreign host too', () {
      expect(classify('lumi://coures/abc'), isA<IgnoreLink>());
      expect(classify('https://example.com/share/class/a'), isA<IgnoreLink>());
    });
  });
}
