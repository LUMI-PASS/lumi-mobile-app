import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/courses/domain/repository/base_course_repository.dart';
import 'package:lumi_pass/feature/courses/presentation/cubit/courses/courses_state.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class CoursesCubit extends ChessCubit<CoursesState> {
  final BaseCourseRepository _courseRepository;
  final SafeExecutionManager _safeExecutionManager;

  CoursesCubit(
    this._courseRepository,
    this._safeExecutionManager,
  ) : super(const CoursesLoadingState());

  void init() {
    _getCourses();
  }

  Future<void> _getCourses() async {
    try {
      final courses = await _safeExecutionManager.makeAsyncSafeExecution(
        function: _courseRepository.getCourses,
      );
      safeEmit(CoursesLoadedState(courses ?? []));
    } on ChessException catch (exception) {
      safeEmit(const CoursesErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}
