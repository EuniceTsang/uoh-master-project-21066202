import 'package:json_annotation/json_annotation.dart';
import 'package:source_code/models/user.dart';
import 'package:source_code/utils/utils.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  @JsonKey(name: CommentFields.comment_id)
  String commentId;

  @JsonKey(name: CommentFields.thread_id)
  String threadId;

  @JsonKey(name: CommentFields.user_id)
  String userId;

  @JsonKey(name: CommentFields.body)
  String body;

  @JsonKey(name: CommentFields.liked_users)
  List<String> likedUsers;

  @JsonKey(name: CommentFields.post_time, fromJson: DateTime.parse, toJson: Utils.dateTimeToString)
  DateTime postTime;

  @JsonKey(ignore: true)
  AppUser? author;

  Comment({
    required this.commentId,
    required this.threadId,
    required this.userId,
    required this.body,
    required this.likedUsers,
    required this.postTime,
    this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

class CommentFields {
  static const collection = 'comment';
  static const comment_id = 'comment_id';
  static const thread_id = 'thread_id';
  static const user_id = 'user_id';
  static const body = 'body';
  static const liked_users = 'liked_users';
  static const post_time = 'post_time';
}
