import 'package:founders_academy/feature/courses/data/model/course/course_data.dart';
import 'package:founders_academy/feature/home/data/model/afisha/afisha_data.dart';
import 'package:founders_academy/feature/home/data/model/book/book_data.dart';
import 'package:founders_academy/feature/home/data/model/grandmaster/grandmaster_data.dart';
import 'package:founders_academy/feature/home/data/model/live_stream/live_stream_data.dart';
import 'package:founders_academy/feature/home/data/model/news/news_data.dart';
import 'package:founders_academy/feature/home/data/model/review_matches/review_matches_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  HomeState._();

  factory HomeState({
    @Default(true) bool isLoading,
    @Default([]) List<AfishaData> afishaList,
    @Default([]) List<NewsData> newsList,
    @Default([]) List<ReviewMatchData> reviewMatchesList,
    @Default([]) List<BookData> bookList,
    @Default([]) List<GrandmasterData> grandmastersList,
    @Default(null) LiveStreamData? liveStream,
    CourseData? activeCourse,
  }) = _HomeState;

  late final bool hasActiveCourse = activeCourse != null;

  late final bool hasLiveStream = liveStream != null;
}
