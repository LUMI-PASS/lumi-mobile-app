// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'books_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BooksResponse _$BooksResponseFromJson(Map<String, dynamic> json) =>
    BooksResponse(
      paginationData:
          PaginationData.fromJson(json['pagination'] as Map<String, dynamic>),
      books: (json['data'] as List<dynamic>?)
          ?.map((e) => BookData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BooksResponseToJson(BooksResponse instance) =>
    <String, dynamic>{
      'data': instance.books,
      'pagination': instance.paginationData,
    };

BookResponse _$BookResponseFromJson(Map<String, dynamic> json) => BookResponse(
      book: json['data'] == null
          ? null
          : BookData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookResponseToJson(BookResponse instance) =>
    <String, dynamic>{
      'data': instance.book,
    };
