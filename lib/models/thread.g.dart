// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Thread _$ThreadFromJson(Map<String, dynamic> json) => Thread(
      threadId: json['thread_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      postTime: DateTime.parse(json['post_time'] as String),
      userId: json['user_id'] as String,
      likedUsers: (json['liked_users'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ThreadToJson(Thread instance) => <String, dynamic>{
      'thread_id': instance.threadId,
      'title': instance.title,
      'body': instance.body,
      'post_time': Utils.dateTimeToString(instance.postTime),
      'user_id': instance.userId,
      'liked_users': instance.likedUsers,
    };
