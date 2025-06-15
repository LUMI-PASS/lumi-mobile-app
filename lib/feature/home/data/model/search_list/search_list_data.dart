import 'package:founders_academy/feature/courses/data/model/course/course_data.dart';
import 'package:founders_academy/feature/home/data/model/afisha/afisha_data.dart';
import 'package:founders_academy/feature/home/data/model/book/book_data.dart';
import 'package:founders_academy/feature/home/data/model/grandmaster/grandmaster_data.dart';
import 'package:founders_academy/feature/home/data/model/news/news_data.dart';
import 'package:founders_academy/feature/home/data/model/review_matches/review_matches_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_list_data.g.dart';

@JsonSerializable()
class SearchListData {
  @JsonKey(name: 'afisha')
  final List<AfishaData> afisha;
  @JsonKey(name: 'books')
  final List<BookData> books;
  @JsonKey(name: 'courses')
  final List<CourseData> courses;
  @JsonKey(name: 'grandmasters')
  final List<GrandmasterData> grandmasters;
  @JsonKey(name: 'news')
  final List<NewsData> news;
  @JsonKey(name: 'reviews')
  final List<ReviewMatchData> reviewMatches;

  const SearchListData({
    this.afisha = const [],
    this.books = const [],
    this.courses = const [],
    this.grandmasters = const [],
    this.news = const [],
    this.reviewMatches = const [],
  });

  bool get isEmpty =>
      news.isEmpty &&
      afisha.isEmpty &&
      books.isEmpty &&
      courses.isEmpty &&
      reviewMatches.isEmpty &&
      grandmasters.isEmpty;

  factory SearchListData.fromJson(Map<String, dynamic> json) =>
      _$SearchListDataFromJson(json);

  Map<String, dynamic> toJson() => _$SearchListDataToJson(this);
}
