import 'package:json_annotation/json_annotation.dart';
import 'package:source_code/utils/utils.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  @JsonKey(name: TaskFields.task_id)
  String taskId;

  @JsonKey(name: TaskFields.user_id)
  String userId;

  @JsonKey(name: TaskFields.type, fromJson: intToTaskType, toJson: taskTypeToInt)
  TaskType type;

  @JsonKey(name: TaskFields.target)
  int target;

  @JsonKey(name: TaskFields.current)
  int current;

  @JsonKey(name: TaskFields.points)
  int points;

  @JsonKey(name: TaskFields.finished)
  bool finished;

  @JsonKey(
      name: TaskFields.last_update_time, fromJson: DateTime.parse, toJson: Utils.dateTimeToString)
  DateTime lastUpdateTime;

  Task({
    required this.taskId,
    required this.userId,
    required this.type,
    required this.target,
    required this.current,
    required this.points,
    required this.finished,
    required this.lastUpdateTime,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);

  String getTaskDescription() {
    switch (type) {
      case TaskType.Reading:
        return "Read $target ${target == 1 ? "article" : "articles"} in a day";
      case TaskType.ConsistentReading:
        return "Read article(s) for $target consecutive days";
      case TaskType.VocabularyCheckInReading:
        return "Check $target ${target == 1 ? "vocabulary" : "vocabularies"} in an article";
      case TaskType.VocabularyCheck:
        return "Check $target new ${target == 1 ? "vocabulary" : "vocabularies"} through dictionary";
      case TaskType.WordOfTheDay:
        return "Check word of the day";
      case TaskType.ReviseWordHistory:
        return "Revise $target ${target == 1 ? "vocabulary" : "vocabularies"} in history";
      case TaskType.ReplyInForum:
        return "Leave $target ${target == 1 ? "reply" : "replies"} in the forum";
      case TaskType.PostInForum:
        return "Create $target ${target == 1 ? "post" : "posts"} in the forum";
      default:
        throw ArgumentError('Invalid TaskType: $type');
    }
  }

}

class TaskFields {
  static const collection = 'task';
  static const task_id = 'task_id';
  static const user_id = 'user_id';
  static const type = 'type';
  static const target = 'target';
  static const current = 'current';
  static const points = 'points';
  static const finished = 'finished';
  static const last_update_time = 'last_update_time';
}

enum TaskType {
  Reading,
  ConsistentReading,
  VocabularyCheckInReading,
  VocabularyCheck,
  WordOfTheDay,
  ReviseWordHistory,
  ReplyInForum,
  PostInForum,
}

TaskType intToTaskType(int value) {
  switch (value) {
    case 1:
      return TaskType.Reading;
    case 2:
      return TaskType.ConsistentReading;
    case 3:
      return TaskType.VocabularyCheckInReading;
    case 4:
      return TaskType.VocabularyCheck;
    case 5:
      return TaskType.WordOfTheDay;
    case 6:
      return TaskType.ReviseWordHistory;
    case 7:
      return TaskType.ReplyInForum;
    case 8:
      return TaskType.PostInForum;
    default:
      throw ArgumentError('Invalid value for TaskType: $value');
  }
}

int taskTypeToInt(TaskType type) {
  switch (type) {
    case TaskType.Reading:
      return 1;
    case TaskType.ConsistentReading:
      return 2;
    case TaskType.VocabularyCheckInReading:
      return 3;
    case TaskType.VocabularyCheck:
      return 4;
    case TaskType.WordOfTheDay:
      return 5;
    case TaskType.ReviseWordHistory:
      return 6;
    case TaskType.ReplyInForum:
      return 7;
    case TaskType.PostInForum:
      return 8;
    default:
      throw ArgumentError('Invalid TaskType: $type');
  }
}
