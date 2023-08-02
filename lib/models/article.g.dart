// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Article _$ArticleFromJson(Map<String, dynamic> json) => Article(
      url: json['url'] as String,
      imageUrl: json['image_url'] as String,
      title: json['title'] as String,
      searchTime: DateTime.parse(json['search_time'] as String),
      userId: json['user_id'] as String,
      abstract: json['abstract'] as String,
      original: json['original'] as String?,
    );

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
      'url': instance.url,
      'image_url': instance.imageUrl,
      'title': instance.title,
      'search_time': Utils.dateTimeToString(instance.searchTime),
      'user_id': instance.userId,
      'abstract': instance.abstract,
      'original': instance.original,
    };
