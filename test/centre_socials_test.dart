import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/socials/centre_socials.dart';

/// A catalogue centre's accounts are the only thing on its page a parent can
/// act on — there is no Book button — so a row that does not open is a dead
/// end. The console stores whatever a human typed (`@lumipass` as readily as
/// `instagram.com/lumipass`), which is what these tests pin down.
void main() {
  group('reading a socials key off the wire', () {
    test('resolves every network the backend sends today', () {
      expect(SocialNetwork.fromKey('instagram'), SocialNetwork.instagram);
      expect(SocialNetwork.fromKey('telegram'), SocialNetwork.telegram);
      expect(SocialNetwork.fromKey('facebook'), SocialNetwork.facebook);
      expect(SocialNetwork.fromKey('youtube'), SocialNetwork.youtube);
      expect(SocialNetwork.fromKey('tiktok'), SocialNetwork.tiktok);
      expect(SocialNetwork.fromKey('website'), SocialNetwork.website);
    });

    test('falls back to unknown instead of throwing on a new network', () {
      expect(SocialNetwork.fromKey('threads'), SocialNetwork.unknown);
      expect(SocialNetwork.fromKey(null), SocialNetwork.unknown);
      expect(SocialNetwork.fromKey(''), SocialNetwork.unknown);
    });
  });

  group('a handle becomes a link', () {
    test('a bare handle lands on the network', () {
      expect(SocialNetwork.instagram.urlFor('@lumipass'),
          'https://instagram.com/lumipass');
      expect(SocialNetwork.telegram.urlFor('lumipass'),
          'https://t.me/lumipass');
      expect(SocialNetwork.facebook.urlFor('@lumipass'),
          'https://facebook.com/lumipass');
    });

    test('tiktok and youtube keep the @ in the path, the others drop it', () {
      expect(SocialNetwork.tiktok.urlFor('@lumipass'),
          'https://tiktok.com/@lumipass');
      expect(SocialNetwork.youtube.urlFor('lumipass'),
          'https://youtube.com/@lumipass');
      expect(SocialNetwork.instagram.urlFor('@lumipass'),
          isNot(contains('/@')));
    });

    test('a dot does not make a handle a domain', () {
      // Plenty of Instagram names have one. Reading `lumi.pass` as a host
      // would send a parent to a site that does not exist.
      expect(SocialNetwork.instagram.urlFor('lumi.pass'),
          'https://instagram.com/lumi.pass');
    });

    test('a link is taken as it stands, with its scheme filled in', () {
      expect(SocialNetwork.instagram.urlFor('https://instagram.com/lumipass'),
          'https://instagram.com/lumipass');
      expect(SocialNetwork.instagram.urlFor('instagram.com/lumipass'),
          'https://instagram.com/lumipass');
      expect(SocialNetwork.telegram.urlFor('t.me/lumipass'),
          'https://t.me/lumipass');
    });

    test('a website is always a domain, never a handle', () {
      expect(SocialNetwork.website.urlFor('lumipass.uz'),
          'https://lumipass.uz');
      expect(SocialNetwork.website.urlFor('https://lumipass.uz'),
          'https://lumipass.uz');
    });

    test('an unmodelled network only resolves when it is already a link', () {
      expect(SocialNetwork.unknown.urlFor('threads.net/@lumipass'),
          'https://threads.net/@lumipass');
      // No handle convention to guess at, so there is nothing to open.
      expect(SocialNetwork.unknown.urlFor('lumipass'), isNull);
    });
  });

  group('what the row prints', () {
    test('a social account shows its handle, not the URL', () {
      expect(SocialNetwork.instagram.labelFor('https://instagram.com/lumipass'),
          '@lumipass');
      expect(SocialNetwork.instagram.labelFor('lumipass'), '@lumipass');
      expect(SocialNetwork.telegram.labelFor('t.me/lumipass'), '@lumipass');
    });

    test('a website shows its bare domain', () {
      expect(SocialNetwork.website.labelFor('https://www.lumipass.uz/'),
          'lumipass.uz');
    });
  });

  group('the whole set', () {
    test('is ordered by network, not by the order the keys arrived', () {
      final socials = CentreSocials.fromJson(const {
        'website': 'lumipass.uz',
        'tiktok': '@lumipass',
        'instagram': '@lumipass',
      });
      expect(
        socials.links.map((l) => l.network),
        [SocialNetwork.instagram, SocialNetwork.tiktok, SocialNetwork.website],
      );
    });

    test('drops blank values rather than showing an empty row', () {
      final socials = CentreSocials.fromJson(const {
        'instagram': '@lumipass',
        'telegram': '   ',
        'facebook': '',
      });
      expect(socials.links.map((l) => l.network), [SocialNetwork.instagram]);
    });

    test('keeps an unmodelled key, and hides it when it cannot open', () {
      final socials = CentreSocials.fromJson(const {
        'threads': 'lumipass',
        'instagram': '@lumipass',
      });
      expect(socials.links.length, 2);
      expect(socials.openable.map((l) => l.network),
          [SocialNetwork.instagram]);
    });

    test('an absent socials object is empty, not null', () {
      expect(CentreSocials.fromJson(const {}).isEmpty, isTrue);
      expect(CentreSocials.empty.openable, isEmpty);
    });
  });

  group('a catalogue activity', () {
    ClassFullModel parse(Map<String, dynamic> json) =>
        ClassFullModel.fromJson(json);

    test('is never bookable, however healthy it otherwise looks', () {
      final activity = parse({
        '_id': 'a1',
        'is_catalog': true,
        'is_visible': true,
        'status': 'approved',
      });
      expect(activity.isCatalog, isTrue);
      expect(activity.isBookable, isFalse);
    });

    test('inherits the flag from its venue', () {
      final activity = parse({
        '_id': 'a1',
        'branch_id': {'_id': 'b1', 'is_catalog': true},
      });
      expect(activity.isCatalog, isTrue);
      expect(activity.branch?.isCatalog, isTrue);
      expect(activity.isBookable, isFalse);
    });

    test('carries the centre\'s accounts', () {
      final activity = parse({
        '_id': 'a1',
        'is_catalog': true,
        'socials': {'instagram': '@lumipass'},
      });
      expect(activity.socials.openable.single.url,
          'https://instagram.com/lumipass');
    });

    test('a real partner has neither the flag nor any accounts', () {
      final activity = parse({'_id': 'a1', 'status': 'approved'});
      expect(activity.isCatalog, isFalse);
      expect(activity.socials.isEmpty, isTrue);
      expect(activity.isBookable, isTrue);
    });
  });

  group('a courses-plan centre\'s course', () {
    test('carries the centre\'s accounts apart from the catalogue field', () {
      final course = ClassFullModel.fromJson({
        '_id': 'c1',
        'is_course': true,
        'contact_socials': {'telegram': '@centre', 'website': 'centre.uz'},
      });
      expect(course.contactSocials.openable.map((l) => l.network),
          [SocialNetwork.telegram, SocialNetwork.website]);
      // Not `socials`: that one means "catalogue venue, nothing to book".
      expect(course.socials.isEmpty, isTrue);
      expect(course.isCatalog, isFalse);
      expect(course.isBookable, isTrue);
    });

    test('an older payload without the field has none', () {
      final course = ClassFullModel.fromJson({'_id': 'c1', 'is_course': true});
      expect(course.contactSocials.isEmpty, isTrue);
    });
  });
}
