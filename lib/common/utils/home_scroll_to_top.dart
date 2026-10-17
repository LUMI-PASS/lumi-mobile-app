import 'package:flutter/foundation.dart';

/// Bumped when the Home tab is tapped while Home is already showing: the feed
/// scrolls back to its top, as Instagram's and Telegram's do. A tap from
/// another tab only switches to Home and leaves its place alone.
final ValueNotifier<int> homeScrollToTop = ValueNotifier<int>(0);
