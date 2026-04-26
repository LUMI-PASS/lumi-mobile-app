import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

class ShortsFeed {
  static List<HomClass>? pendingClasses;
  static int pendingIndex = 0;

  static bool get hasPending =>
      pendingClasses != null && pendingClasses!.isNotEmpty;

  static void set(List<HomClass> classes, int index) {
    pendingClasses = classes;
    pendingIndex = index.clamp(0, classes.length - 1);
  }

  static void clear() {
    pendingClasses = null;
    pendingIndex = 0;
  }
}
