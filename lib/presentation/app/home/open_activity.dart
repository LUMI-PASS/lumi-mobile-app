import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

/// Open an activity card — whatever kind of activity it turns out to be.
///
/// A COURSE is bought as a package (trial lessons, or the whole course/level),
/// so it must not land on the ordinary class detail screen with its per-session,
/// age-tier booking flow. That distinction has to be made at every entry point:
/// the home rows, "see all", search, the branch page (which asks for
/// `include_courses`), shorts and deep links. Doing it here — rather than at
/// each call site — is what stops one of them quietly opening the wrong screen
/// again.
Future<void> openActivity(BuildContext context, HomClass? item) {
  final activity = item ?? const HomClass();
  if (activity.isCourse == true) {
    return context.router.push(CourseDetailRoute(course: activity));
  }
  return context.router.push(ClassDetailRoute(classModel: activity));
}
