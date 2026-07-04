import 'package:flutter/foundation.dart';

/// Global notifier for the authenticated parent's display name.
/// Write to this from any screen that updates the user's name so the
/// home header re-renders immediately without a full network refresh.
final displayNameNotifier = ValueNotifier<String?>(null);
