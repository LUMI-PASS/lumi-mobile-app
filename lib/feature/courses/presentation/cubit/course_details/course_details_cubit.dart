import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/courses/data/model/course/course_data.dart';
import 'package:lumi_pass/feature/courses/domain/repository/base_course_repository.dart';
import 'package:lumi_pass/feature/courses/presentation/cubit/course_details/course_details_state.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class CourseDetailsCubit extends ChessCubit<CourseDetailsState> {
  final BaseCourseRepository _courseRepository;
  final SafeExecutionManager _safeExecutionManager;

  CourseDetailsCubit(
    this._courseRepository,
    this._safeExecutionManager,
  ) : super(const CourseDetailsLoadingState());

  void init(CourseData courseData) {
    _getCourseDetails(courseData);
  }

  Future<void> _getCourseDetails(CourseData courseData) async {
    try {
      final course = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _courseRepository.getCourseById(id: courseData.id),
      );

      final moduleList = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _courseRepository.getCourseModules(id: courseData.id),
      );

      safeEmit(CourseDetailsLoadedState(
        moduleList: moduleList ?? [],
        isEnrolled: course?.isEnrolled ?? false,
        progress: course?.progress ?? 0,
      ));
    } on ChessException catch (exception) {
      safeEmit(const CourseDetailsErrorState());
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> enrollToCourse(String id) async {
    final currentState = state;
    if (currentState is! CourseDetailsLoadedState) return;
    try {
      await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _courseRepository.enrollToCourse(id: id),
      );

      safeEmit(const CourseDetailsEnrollSucceededState());
      safeEmit(currentState.copyWith(
        isEnrolled: true,
        progress: 0,
        isStateUpdated: true,
      ));
    } on ChessException catch (exception) {
      safeEmit(const CourseDetailsEnrollFailedState());
      safeEmit(const CourseDetailsErrorState());
      throw UnknownChessException(exception.toString());
    }
  }

  Future<bool> getCertificate(String courseId) async {
    try {
      final getCertificate = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _courseRepository.getCertificate(id: courseId),
      );
      return getCertificate;
    } on ChessException catch (exception) {
      safeEmit(const CourseDetailsEnrollFailedState());
      safeEmit(const CourseDetailsErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}
