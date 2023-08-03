// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      taskId: json['task_id'] as String,
      userId: json['user_id'] as int,
      type: intToTaskType(json['type'] as int),
      target: json['target'] as int,
      current: json['current'] as int,
      points: json['points'] as int,
      finished: json['finished'] as bool,
      lastUpdateTime: DateTime.parse(json['last_update_time'] as String),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'task_id': instance.taskId,
      'user_id': instance.userId,
      'type': taskTypeToInt(instance.type),
      'target': instance.target,
      'current': instance.current,
      'points': instance.points,
      'finished': instance.finished,
      'last_update_time': Utils.dateTimeToString(instance.lastUpdateTime),
    };
