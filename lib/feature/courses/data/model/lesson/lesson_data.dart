import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson_data.g.dart';

enum LessonStatus { active, inactive, completed }

@JsonSerializable()
class LessonData {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(name: 'youtube_link')
  final String youtubeLink;
  @JsonKey(name: 'download_link')
  final String downloadLink;
  @JsonKey(name: 'is_open')
  final bool? isOpen;
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @JsonKey(name: 'duration')
  final int? duration;
  @JsonKey(name: 'has_quiz')
  final bool? hasQuiz;

  const LessonData({
    required this.id,
    required this.name,
    required this.description,
    required this.youtubeLink,
    required this.downloadLink,
    this.duration,
    this.isOpen = true,
    this.isCompleted = true,
    this.hasQuiz = false,
    this.shortDescription,
  });

  factory LessonData.fromJson(Map<String, dynamic> json) =>
      _$LessonDataFromJson(json);

  Map<String, dynamic> toJson() => _$LessonDataToJson(this);

  String get extractVideoLink {
    if (youtubeLink.contains("live")) {
      RegExp regExp = RegExp(r'(https://www\.youtube\.com/live/[\w-]+)');
      RegExpMatch match = regExp.firstMatch(youtubeLink)!;
      return match.group(0)!.replaceAll("live/", "watch?v=");
    }

    return youtubeLink;
  }

  LessonStatus get status {
    if (isCompleted) return LessonStatus.completed;
    if (isOpen ?? true) return LessonStatus.active;
    return LessonStatus.inactive;
  }

  @override
  String toString() {
    return 'LessonData{id: $id, name: $name, description: $description, '
        'shortDescription: $shortDescription, youtubeLink: $youtubeLink, '
        'downloadLink: $downloadLink, isOpen: $isOpen, isCompleted: $isCompleted}';
  }
}
