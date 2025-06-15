// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginationData _$PaginationDataFromJson(Map<String, dynamic> json) =>
    PaginationData(
      totalRecords: json['total_records'] as int,
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      nextPage: json['next_page'] as int?,
      prevPage: json['prev_page'] as int?,
    );

Map<String, dynamic> _$PaginationDataToJson(PaginationData instance) =>
    <String, dynamic>{
      'total_records': instance.totalRecords,
      'current_page': instance.currentPage,
      'total_pages': instance.totalPages,
      'next_page': instance.nextPage,
      'prev_page': instance.prevPage,
    };
