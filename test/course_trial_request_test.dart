import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';

/// The free trial-lesson request block on a course detail. The server decides
/// who may ask; the app only reads the verdict, so these pin the parsing and
/// which groups the sheet may offer.
void main() {
  Map<String, dynamic> course({Object? trialRequest, String type = 'course'}) =>
      {
        'activity_id': 'a1',
        'type': type,
        'has_subcourses': true,
        'subcourses': const [],
        if (trialRequest != null) 'trial_request': trialRequest,
      };

  test('reads each group and its verdict', () {
    final d = CourseDetail.fromJson(course(trialRequest: {
      'can_request': true,
      'requested': false,
      'groups': [
        {'subcourse_id': 'g1', 'name': 'Beginner', 'can_request': true},
        {
          'subcourse_id': 'g2',
          'name': 'Advanced',
          'can_request': false,
          'blocked_reason': 'not_configured',
        },
      ],
    }));

    final tr = d.trialRequest!;
    expect(tr.canRequest, isTrue);
    expect(tr.groups, hasLength(2));
    expect(tr.groups[1].blockedReason, CourseBlockedReason.notConfigured);
    // Only the group that takes a request is offered.
    expect(tr.openGroups.map((g) => g.subcourseId), ['g1']);
  });

  test('does not offer a group that already has an open request', () {
    final d = CourseDetail.fromJson(course(trialRequest: {
      'can_request': true,
      'requested': true,
      'entry_id': 'e1',
      'groups': [
        {
          'subcourse_id': 'g1',
          'can_request': true,
          'requested': true,
          'entry_id': 'e1'
        },
      ],
    }));

    expect(d.trialRequest!.requested, isTrue);
    expect(d.trialRequest!.openGroups, isEmpty);
  });

  test('a course without groups is one row with no id', () {
    final d = CourseDetail.fromJson(course(trialRequest: {
      'can_request': true,
      'groups': [
        {'subcourse_id': null, 'name': null, 'can_request': true},
      ],
    }));

    expect(d.trialRequest!.openGroups.single.subcourseId, isNull);
  });

  test('absent on an older server, an intake, or an activities-only centre',
      () {
    expect(CourseDetail.fromJson(course()).trialRequest, isNull);
    expect(
      CourseDetail.fromJson(course(type: 'intake', trialRequest: null))
          .trialRequest,
      isNull,
    );
  });

  test('an unknown blocked reason degrades rather than throwing', () {
    final g = CourseTrialRequestGroup.fromJson(
        {'can_request': false, 'blocked_reason': 'something_new'});
    expect(g.blockedReason, CourseBlockedReason.unknown);
  });
}
