// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationResponse _$NotificationResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationResponse(
      paginationData:
          PaginationData.fromJson(json['pagination'] as Map<String, dynamic>),
      notificationList: (json['data'] as List<dynamic>?)
          ?.map((e) => NotificationData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NotificationResponseToJson(
        NotificationResponse instance) =>
    <String, dynamic>{
      'data': instance.notificationList,
      'pagination': instance.paginationData,
    };

NotificationItemResponse _$NotificationItemResponseFromJson(
        Map<String, dynamic> json) =>
    NotificationItemResponse(
      notificationData: json['data'] == null
          ? null
          : NotificationData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NotificationItemResponseToJson(
        NotificationItemResponse instance) =>
    <String, dynamic>{
      'data': instance.notificationData,
    };
