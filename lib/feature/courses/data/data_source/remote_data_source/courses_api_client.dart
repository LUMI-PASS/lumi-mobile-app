import 'package:founders_academy/core/api/api_response.dart';
import 'package:founders_academy/di/module/api_client_module.dart';
import 'package:founders_academy/feature/courses/data/model/course/course_response.dart';
import 'package:founders_academy/feature/courses/data/model/enroll/enroll_data.dart';
import 'package:founders_academy/feature/courses/data/model/lesson/lesson_response.dart';
import 'package:founders_academy/feature/courses/data/model/module/module_response.dart';
import 'package:founders_academy/feature/courses/data/model/order/order.dart';
import 'package:founders_academy/feature/courses/data/model/quiz/quiz_data.dart';
import 'package:founders_academy/feature/courses/data/model/quiz_submission/quiz_result.dart';
import 'package:founders_academy/feature/courses/data/model/quiz_submission/submit_quiz_data.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'courses_api_client.g.dart';

@injectable
@RestApi()
abstract class CoursesApiClient {
  @factoryMethod
  factory CoursesApiClient(@authorizedApiClient Dio dio) = _CoursesApiClient;

  @GET('/api/courses')
  Future<ApiResponse<CoursesResponse>> getCourses();

  @GET('/api/courses/active')
  Future<ApiResponse<CourseResponse>> getActiveCourse();

  @GET('/api/courses/{id}/modules')
  Future<ApiResponse<ModulesResponse>> getCourseModules(
    @Path('id') String id,
  );

  @GET('/api/courses/{id}')
  Future<ApiResponse<CourseResponse>> getCourseById(
    @Path('id') String id,
  );

  @GET('/api/courses/{id}/certificate')
  Future<ApiResponse<dynamic>> getCertificate(
    @Path('id') String id,
  );

  @POST('/api/courses/{id}/enroll')
  Future<ApiResponse<EnrollData>> enrollToCourse(
    @Path('id') String id,
  );

  @GET('/api/lessons/{id}')
  Future<ApiResponse<LessonResponse>> getLessonById(
    @Path('id') String id,
  );

  @POST('/api/lessons/{id}/complete')
  Future<ApiResponse<LessonResponse>> completeLesson(
    @Path('id') String id,
  );
  @POST('/api/purchase')
  Future<ApiResponse<dynamic>> createPurchase(
    @Body() PurchaseRequest request,
  );

  @GET('/api/lessons/{id}/quizzes')
  Future<ApiResponse<QuizResponse>> getLessonQuizzes(
    @Path('id') String id,
  );

  @POST('/api/lessons/{id}/quizzes/submit')
  Future<ApiResponse<QuizResult>> submitQuiz(
    @Path('id') String id,
    @Body() List<SubmitQuizData> quizData,
  );
}
