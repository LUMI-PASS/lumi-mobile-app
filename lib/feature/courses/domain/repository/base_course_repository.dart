import 'package:lumi_pass/feature/courses/data/model/course/course_data.dart';
import 'package:lumi_pass/feature/courses/data/model/enroll/enroll_data.dart';
import 'package:lumi_pass/feature/courses/data/model/lesson/lesson_data.dart';
import 'package:lumi_pass/feature/courses/data/model/module/module_data.dart';
import 'package:lumi_pass/feature/courses/data/model/order/order.dart';
import 'package:lumi_pass/feature/courses/data/model/quiz/quiz_data.dart';
import 'package:lumi_pass/feature/courses/data/model/quiz_submission/quiz_result.dart';
import 'package:lumi_pass/feature/courses/data/model/quiz_submission/submit_quiz_data.dart';

abstract interface class BaseCourseRepository {
  Future<List<CourseData>?> getCourses();

  Future<CourseData?> getActiveCourse();

  Future<List<ModuleData>?> getCourseModules({required String id});

  Future<CourseData?> getCourseById({required String id});

  Future<LessonData?> getLessonById({required String id});

  Future<EnrollData?> enrollToCourse({required String id});

  Future<LessonData?> completeLesson({required String id});

  Future<dynamic> getCertificate({required String id});

  Future<dynamic> createOrder({required PurchaseRequest purchase});

  Future<bool> getQuizLessonCompletion({
    required String userId,
    required String lessonId,
  });

  Future<bool> storeQuizLessonCompletion({
    required String userId,
    required String lessonId,
  });

  Future<List<QuizData>?> getLessonQuizzes({required String id});

  Future<QuizResult> submitQuiz({
    required String id,
    required List<SubmitQuizData> submitQuizData,
  });
}
