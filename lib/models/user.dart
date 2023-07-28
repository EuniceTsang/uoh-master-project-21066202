import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: UserFields.user_id)
  String userId;

  @JsonKey(name: UserFields.username)
  String username;

  @JsonKey(name: UserFields.email)
  String email;

  @JsonKey(name: UserFields.target_reading)
  int? targetReading;

  @JsonKey(name: UserFields.target_time)
  String? targetTime;

  @JsonKey(name: UserFields.level)
  int level;

  @JsonKey(name: UserFields.last_level_update, fromJson: DateTime.parse)
  DateTime lastLevelUpdate;

  User({
    required this.userId,
    required this.username,
    required this.email,
    this.targetReading,
    this.targetTime,
    required this.level,
    required this.lastLevelUpdate,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

class UserFields {
  static const collection = 'user';
  static const user_id = 'user_id';
  static const email = 'email';
  static const username = 'username';
  static const target_reading = 'target_reading';
  static const target_time = 'target_time';
  static const level = 'level';
  static const last_level_update = 'last_level_update';
}