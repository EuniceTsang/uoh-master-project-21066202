import 'package:json_annotation/json_annotation.dart';
import 'package:source_code/utils/preference.dart';
import 'package:source_code/utils/utils.dart';

part 'article.g.dart';

@JsonSerializable()
class Article {
  @JsonKey(name: ArticleFields.url)
  String url;

  @JsonKey(name: ArticleFields.image_url)
  String imageUrl;

  @JsonKey(name: ArticleFields.title)
  String title;

  @JsonKey(
      name: ArticleFields.search_time, fromJson: DateTime.parse, toJson: Utils.dateTimeToString)
  DateTime searchTime;

  @JsonKey(name: ArticleFields.user_id)
  String userId;

  @JsonKey(name: ArticleFields.abstract)
  String abstract;

  @JsonKey(name: ArticleFields.original)
  String? original;

  @JsonKey(ignore: true)
  String fullText;

  Article({
    required this.url,
    required this.imageUrl,
    required this.title,
    required this.searchTime,
    required this.userId,
    required this.abstract,
    this.fullText = '',
    this.original,
  });

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleToJson(this);

  static Article? parseFromArticleSearchApi(Map<String, dynamic> json) {
    try {
      String _url = json['web_url'];
      String _source = json['source'];
      String _imageUrl = '';
      List multimedia = json['multimedia'];
      for (dynamic element in multimedia) {
        if (_source == "The New York Times" && element['subtype'] == "tmagSF") {
          _imageUrl = "https://www.nytimes.com/" + element['url'];
          break;
        }
        if (_source == "Wirecutter" && element['subtype'] == "mediumThreeByTwo330") {
          _imageUrl = "https://cdn.thewirecutter.com/" + element['url'];
          break;
        }
      }
      String _title = json['headline']['main'];
      String _original = json['byline']['original'];
      String _abstract = json['abstract'];
      return Article(
          url: _url,
          imageUrl: _imageUrl,
          title: _title,
          searchTime: DateTime.now(),
          userId: Preferences().uid,
          abstract: _abstract,
          original: _original.isEmpty ? null : _original);
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      return null;
    }
  }

  static Article? parseFromMostPopularApi(Map<String, dynamic> json) {
    try {
      String _url = json['url'];
      String _imageUrl = '';
      List media = json['media'];
      for (dynamic element in media) {
        if (element['type'] == "image") {
          List media_metadata = element["media-metadata"];
          for (dynamic metadata in media_metadata) {
            if (metadata['format'] == "mediumThreeByTwo210") {
              _imageUrl = metadata['url'];
            }
          }
          break;
        }
      }
      String _title = json['title'];
      String _original = json['byline'];
      String _abstract = json['abstract'];
      return Article(
          url: _url,
          imageUrl: _imageUrl,
          title: _title,
          searchTime: DateTime.now(),
          userId: Preferences().uid,
          abstract: _abstract,
          original: _original.isEmpty ? null : _original);
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      return null;
    }
  }

  @override
  String toString() {
    return 'Article{url: $url, imageUrl: $imageUrl, title: $title, searchTime: $searchTime, '
        'userId: $userId, abstract: $abstract, original: $original, fullText: $fullText}';
  }
}

class ArticleFields {
  static const collection = 'article';
  static const url = 'url';
  static const image_url = 'image_url';
  static const title = 'title';
  static const search_time = 'search_time';
  static const user_id = 'user_id';
  static const abstract = 'abstract';
  static const original = 'original';
}
