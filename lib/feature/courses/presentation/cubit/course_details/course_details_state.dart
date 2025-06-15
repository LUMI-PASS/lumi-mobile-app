import 'package:founders_academy/feature/courses/data/model/module/module_data.dart';

sealed class CourseDetailsState {
  const CourseDetailsState();
}

class CourseDetailsLoadingState extends CourseDetailsState {
  const CourseDetailsLoadingState();
}

class CourseDetailsLoadedState extends CourseDetailsState {
  final List<ModuleData> moduleList;
  final bool isEnrolled;
  final int progress;
  final bool isStateUpdated;

  const CourseDetailsLoadedState({
    required this.moduleList,
    required this.isEnrolled,
    required this.progress,
    this.isStateUpdated = false,
  });

  CourseDetailsLoadedState copyWith({
    List<ModuleData>? moduleLest,
    bool? isEnrolled,
    int? progress,
    bool? isStateUpdated,
  }) {
    return CourseDetailsLoadedState(
      moduleList: moduleLest ?? moduleList,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      progress: progress ?? this.progress,
      isStateUpdated: isStateUpdated ?? this.isStateUpdated,
    );
  }
}

class CourseDetailsErrorState extends CourseDetailsState {
  const CourseDetailsErrorState();
}

class CourseDetailsEnrollSucceededState extends CourseDetailsState {
  const CourseDetailsEnrollSucceededState();
}

class CourseDetailsEnrollFailedState extends CourseDetailsState {
  const CourseDetailsEnrollFailedState();
}
