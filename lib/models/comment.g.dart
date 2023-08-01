// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      commentId: json['comment_id'] as String,
      threadId: json['thread_id'] as String,
      userId: json['user_id'] as String,
      body: json['body'] as String,
      likedUsers: (json['liked_users'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      postTime: DateTime.parse(json['post_time'] as String),
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'comment_id': instance.commentId,
      'thread_id': instance.threadId,
      'user_id': instance.userId,
      'body': instance.body,
      'liked_users': instance.likedUsers,
      'post_time': Utils.dateTimeToString(instance.postTime),
    };
