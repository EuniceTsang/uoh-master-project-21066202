import 'package:json_annotation/json_annotation.dart';
import 'package:source_code/utils/utils.dart';

part 'task.g.dart';

@JsonSerializable()
class Task {
  @JsonKey(name: TaskFields.task_id)
  String taskId;

  @JsonKey(name: TaskFields.user_id)
  int userId;

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
  ReadTargetNumberOfBooks,
  ConsistentReading,
  VocabularyCheckInReading,
  VocabularyCheck,
  WordRevision,
  ReviseWordHistory,
  ReplyInForum,
  PostInForum,
}

TaskType intToTaskType(int value) {
  switch (value) {
    case 1:
      return TaskType.ReadTargetNumberOfBooks;
    case 2:
      return TaskType.ConsistentReading;
    case 3:
      return TaskType.VocabularyCheckInReading;
    case 4:
      return TaskType.VocabularyCheck;
    case 5:
      return TaskType.WordRevision;
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
    case TaskType.ReadTargetNumberOfBooks:
      return 1;
    case TaskType.ConsistentReading:
      return 2;
    case TaskType.VocabularyCheckInReading:
      return 3;
    case TaskType.VocabularyCheck:
      return 4;
    case TaskType.WordRevision:
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
