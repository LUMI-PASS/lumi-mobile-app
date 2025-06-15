import 'package:founders_academy/feature/courses/data/model/course/course_data.dart';

sealed class CoursesState {
  const CoursesState();
}

class CoursesLoadingState extends CoursesState {
  const CoursesLoadingState();
}

class CoursesLoadedState extends CoursesState {
  final List<CourseData> courseList;
  const CoursesLoadedState(this.courseList);
}

class CoursesErrorState extends CoursesState {
  const CoursesErrorState();
}
