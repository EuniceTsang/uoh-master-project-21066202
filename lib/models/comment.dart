import 'package:json_annotation/json_annotation.dart';
import 'package:source_code/utils/utils.dart';
part 'comment.g.dart';

@JsonSerializable()
class Comment {
  @JsonKey(name: CommentFields.user_id)
  String userId;
  @JsonKey(name: CommentFields.body)
  String body;
  @JsonKey(name: CommentFields.liked_users)
  List<String> likedUsers;
  @JsonKey(name: CommentFields.post_time, fromJson: DateTime.parse, toJson: Utils.dateTimeToString)
  DateTime postTime;

  Comment({
    required this.userId,
    required this.body,
    required this.likedUsers,
    required this.postTime,
  });
}

class CommentFields {
  static const collection = 'comment';
  static const user_id = 'user_id';
  static const body = 'body';
  static const liked_users = 'liked_users';
  static const post_time = 'post_time';
}
