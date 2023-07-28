// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      targetReading: json['target_reading'] as int?,
      targetTime: json['target_time'] as String?,
      level: json['level'] as int,
      lastLevelUpdate: DateTime.parse(json['last_level_update'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'target_reading': instance.targetReading,
      'target_time': instance.targetTime,
      'level': instance.level,
      'last_level_update': Utils.dateTimeToString(instance.lastLevelUpdate),
    };
