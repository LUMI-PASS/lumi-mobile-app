import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/feature/courses/data/data_source/local_data_source/lesson_completion_database.dart';
import 'package:lumi_pass/feature/courses/data/data_source/remote_data_source/courses_api_client.dart';
import 'package:lumi_pass/feature/courses/data/model/course/course_data.dart';
import 'package:lumi_pass/feature/courses/data/model/enroll/enroll_data.dart';
import 'package:lumi_pass/feature/courses/data/model/lesson/lesson_data.dart';
import 'package:lumi_pass/feature/courses/data/model/module/module_data.dart';
import 'package:lumi_pass/feature/courses/data/model/order/order.dart';
import 'package:lumi_pass/feature/courses/data/model/quiz/quiz_data.dart';
import 'package:lumi_pass/feature/courses/data/model/quiz_submission/quiz_result.dart';
import 'package:lumi_pass/feature/courses/data/model/quiz_submission/submit_quiz_data.dart';
import 'package:lumi_pass/feature/courses/domain/repository/base_course_repository.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

@Injectable(as: BaseCourseRepository)
class CourseRepository implements BaseCourseRepository {
  final CoursesApiClient _coursesApiClient;
  final LessonCompletionDatabase _lessonCompletionDatabase;

  CourseRepository(this._coursesApiClient, this._lessonCompletionDatabase);

  @override
  Future<List<CourseData>?> getCourses() async {
    try {
      final response = await _coursesApiClient.getCourses();

      return response.result.courses;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<List<ModuleData>?> getCourseModules({required String id}) async {
    try {
      final response = await _coursesApiClient.getCourseModules(id);

      return response.result.modules;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<CourseData?> getCourseById({required String id}) async {
    try {
      final response = await _coursesApiClient.getCourseById(id);

      return response.result.course;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<CourseData?> getActiveCourse() async {
    try {
      final response = await _coursesApiClient.getActiveCourse();

      return response.result.course;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<LessonData?> getLessonById({required String id}) async {
    try {
      final response = await _coursesApiClient.getLessonById(id);

      return response.result.lesson;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<EnrollData?> enrollToCourse({required String id}) async {
    try {
      final response = await _coursesApiClient.enrollToCourse(id);

      return response.result;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<LessonData?> completeLesson({required String id}) async {
    try {
      final response = await _coursesApiClient.completeLesson(id);

      return response.result.lesson;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<bool> getQuizLessonCompletion({
    required String userId,
    required String lessonId,
  }) async {
    try {
      final result = await _lessonCompletionDatabase.read(
        userId: userId,
        lessonId: lessonId,
      );

      if (result == null) return false;

      return true;
    } on IsarError catch (exception) {
      throw ChessException.fromIsarException(exception);
    }
  }

  @override
  Future<bool> storeQuizLessonCompletion({
    required String userId,
    required String lessonId,
  }) async {
    try {
      await _lessonCompletionDatabase.write(
        lessonId: lessonId,
        userId: userId,
      );

      return true;
    } on IsarError catch (exception) {
      throw ChessException.fromIsarException(exception);
    }
  }

  @override
  Future<List<QuizData>?> getLessonQuizzes({required String id}) async {
    try {
      final response = await _coursesApiClient.getLessonQuizzes(id);

      return response.result.data;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<QuizResult> submitQuiz({
    required String id,
    required List<SubmitQuizData> submitQuizData,
  }) async {
    try {
      final response = await _coursesApiClient.submitQuiz(id, submitQuizData);

      return response.result;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future createOrder({required PurchaseRequest purchase}) async {
    try {
      final response = await _coursesApiClient.createPurchase(purchase);

      return response.result;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<dynamic> getCertificate({required String id}) async {
    try {
      final response = await _coursesApiClient.getCertificate(id);

      return response.result.lesson;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }
}
