// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationData _$NotificationDataFromJson(Map<String, dynamic> json) =>
    NotificationData(
      id: json['_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      read: json['read'] as bool? ?? false,
      imageUrl: json['image'] as String?,
      type: $enumDecodeNullable(_$NotificationTypeEnumMap, json['type']),
      entityId: json['entity_id'] as String?,
      date: json['date'] as String,
    );

Map<String, dynamic> _$NotificationDataToJson(NotificationData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'read': instance.read,
      'image': instance.imageUrl,
      'type': _$NotificationTypeEnumMap[instance.type],
      'entity_id': instance.entityId,
      'date': instance.date,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.afisha: 'afisha',
  NotificationType.news: 'news',
  NotificationType.tournament: 'tournament',
  NotificationType.live: 'live',
  NotificationType.grandmaster: 'grandmaster',
  NotificationType.book: 'book',
  NotificationType.course: 'course',
  NotificationType.module: 'module',
  NotificationType.review: 'review_game',
  NotificationType.unknown: '',
};
