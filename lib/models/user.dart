import 'package:json_annotation/json_annotation.dart';
import 'package:source_code/utils/utils.dart';

part 'user.g.dart';

@JsonSerializable()
class AppUser {
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

  @JsonKey(name: UserFields.current_points)
  int currentPoints;

  @JsonKey(name: UserFields.level_points)
  int levelPoints;

  @JsonKey(
      name: UserFields.last_level_update, fromJson: DateTime.parse, toJson: Utils.dateTimeToString)
  DateTime lastLevelUpdate;

  AppUser({
    required this.userId,
    required this.username,
    required this.email,
    this.targetReading,
    this.targetTime,
    required this.level,
    required this.currentPoints,
    required this.levelPoints,
    required this.lastLevelUpdate,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}

class UserFields {
  static const collection = 'user';
  static const user_id = 'user_id';
  static const email = 'email';
  static const username = 'username';
  static const target_reading = 'target_reading';
  static const target_time = 'target_time';
  static const level = 'level';
  static const level_points = 'level_points';
  static const current_points = 'current_points';
  static const last_level_update = 'last_level_update';
}
