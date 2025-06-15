// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookData _$BookDataFromJson(Map<String, dynamic> json) => BookData(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      downloadData:
          DownloadData.fromJson(json['download_link'] as Map<String, dynamic>),
      mutolaaDeepLink: json['mutolaa_deep_link'] as String?,
      author: json['author'] as String,
    );

Map<String, dynamic> _$BookDataToJson(BookData instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'download_link': instance.downloadData,
      'mutolaa_deep_link': instance.mutolaaDeepLink,
      'author': instance.author,
    };
