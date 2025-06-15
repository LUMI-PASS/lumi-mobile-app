// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_report_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PuzzleReportData _$PuzzleReportDataFromJson(Map<String, dynamic> json) =>
    PuzzleReportData(
      body: json['body'] as String?,
      isWrongAnswer: json['is_wrong_answer'] as bool?,
      isTechnicalError: json['is_technical_error'] as bool?,
    );

Map<String, dynamic> _$PuzzleReportDataToJson(PuzzleReportData instance) =>
    <String, dynamic>{
      'body': instance.body,
      'is_wrong_answer': instance.isWrongAnswer,
      'is_technical_error': instance.isTechnicalError,
    };
