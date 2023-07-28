import 'package:json_annotation/json_annotation.dart';
import 'package:source_code/utils/utils.dart';
part 'thread.g.dart';

@JsonSerializable()
class Thread {
  @JsonKey(name: ThreadFields.thread_id)
  String threadId;

  @JsonKey(name: ThreadFields.title)
  String title;

  @JsonKey(name: ThreadFields.body)
  String body;

  @JsonKey(name: ThreadFields.post_time, fromJson: DateTime.parse, toJson: Utils.dateTimeToString)
  DateTime postTime;

  @JsonKey(name: ThreadFields.user_id)
  String userId;

  @JsonKey(name: ThreadFields.liked_users)
  List<String> likedUsers;

  @JsonKey(ignore: true)
  int? commentNumber;

  Thread({
    required this.threadId,
    required this.title,
    required this.body,
    required this.postTime,
    required this.userId,
    required this.likedUsers,
    this.commentNumber,
  });
}

class ThreadFields {
  static const collection = 'thread';
  static const thread_id = 'thread_id';
  static const title = 'title';
  static const body = 'body';
  static const post_time = 'post_time';
  static const user_id = 'user_id';
  static const liked_users = 'liked_users';
}
