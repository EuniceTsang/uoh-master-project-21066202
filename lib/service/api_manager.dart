import 'package:dio/dio.dart';
import 'package:source_code/models/article.dart';
import 'package:source_code/models/word.dart';

class ApiManager {
  late final Dio dio;
  static const dictionaryApiKey = '2f75820c-65b7-4a16-94b9-71bdbd814b96';
  static const dictionaryUrl =
      'https://www.dictionaryapi.com/api/v3/references/learners/json/may?key=2f75820c-65b7-4a16-94b9-71bdbd814b96';
  static const articleApiKey = '6Xx7xWCXQN8FwJXEATFGdJaRXeBFAfUY';

  ApiManager() {
    dio = Dio();
  }

  Future<Word?> searchWord(String word) async {
    try {
      final response = await dio.get(
          'https://www.dictionaryapi.com/api/v3/references/learners/json/$word?key=$dictionaryApiKey');
      if (response.statusCode == 200) {
        Word? wordObj = Word.parseFromApi(word, response.data);
        if (wordObj != null) {
          print("searchWord: " + wordObj.toString());
        }
        return wordObj;
      } else {
        print("${response.statusCode}, ${response.data}");
      }
    } catch (e, stacktrace) {
      print('searchWord Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
    return null;
  }

  Future<String?> getHtml(String url) async {
    final response = await dio.get(url);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      return null;
    }
  }

  Future<List<Article>> searchArticles(String keyword) async {
    List<Article> articles = [];
    try {
      String url =
          "https://api.nytimes.com/svc/search/v2/articlesearch.json?fq=headline:(%22$keyword%22)&sort=relevance&fl=web_url,abstract,headline,byline,multimedia,source&api-key=$articleApiKey";
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> json = response.data;
        List<dynamic> docs = json["response"]["docs"];
        if (docs.isNotEmpty) {
          for (dynamic doc in docs) {
            Article? article = Article.parseFromArticleSearchApi(doc);
            print(article);
            if (article != null) {
              articles.add(article);
            }
          }
        }
      } else {
        print("${response.statusCode}, ${response.data}");
      }
    } catch (e, stacktrace) {
      print('searchArticles Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
    return articles;
  }

  Future<List<Article>> getPopularArticles() async {
    List<Article> articles = [];
    try {
      String url =
          "https://api.nytimes.com/svc/mostpopular/v2/viewed/1.json?api-key=$articleApiKey";
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> json = response.data;
        List<dynamic> docs = json["results"];
        if (docs.isNotEmpty) {
          for (dynamic doc in docs) {
            Article? article = Article.parseFromMostPopularApi(doc);
            print(article);
            if (article != null) {
              articles.add(article);
            }
          }
        }
      } else {
        print("${response.statusCode}, ${response.data}");
      }
    } catch (e, stacktrace) {
      print('getPopularArticles Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
    return articles;
  }
}
