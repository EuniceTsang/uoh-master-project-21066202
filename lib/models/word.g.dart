// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map<String, dynamic> json) => Word(
      word: json['word'] as String,
      userId: json['user_id'] as String,
      searchTime: DateTime.parse(json['search_time'] as String),
    );

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
      'word': instance.word,
      'user_id': instance.userId,
      'search_time': Utils.dateTimeToString(instance.searchTime),
    };
