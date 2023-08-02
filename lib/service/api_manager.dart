import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:source_code/models/article.dart';
import 'package:source_code/models/word.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

class ApiManager {
  late final Dio dio;
  static const dictionaryApiKey = '2f75820c-65b7-4a16-94b9-71bdbd814b96';
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

  Future<String?> getArticleBody(Article article) async {
    String? body;
    try {
      String? htmlContent = await getHtml(article.url);
      dom.Document document = parse(htmlContent);
      dom.Element? articleBody = findTag(document.body, "section", "name", "articleBody");
      String? articleBodyHtml = articleBody?.outerHtml;
      if (articleBodyHtml != null) {
        body = extractParagraphText(articleBodyHtml);
      }
    } catch (e, stacktrace) {
      print('getArticleBody Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
    return body;
  }

  dom.Element? findTag(
      dom.Element? element, String tagName, String attributeName, String attributeValue) {
    if (element != null) {
      if (element.localName == tagName && element.attributes[attributeName] == attributeValue) {
        return element;
      } else {
        for (var child in element.children) {
          var foundTag = findTag(child, tagName, attributeName, attributeValue);
          if (foundTag != null) {
            return foundTag;
          }
        }
      }
    }
    return null;
  }

  String extractParagraphText(String html) {
    dom.Document document = parse(html);
    List<dom.Element> paragraphs = document.getElementsByTagName('p');
    String result = '';
    for (dom.Element paragraph in paragraphs) {
      result += "${paragraph.text}\n";
    }
    return result;
  }

  Future<Word?> getWordOfTheDay() async {
    try {
      String? htmlContent = await getHtml("https://www.merriam-webster.com/word-of-the-day");
      dom.Document document = parse(htmlContent);
      dom.Element? wordOfTheDayElement = findTag(document.body, "h2", "class", "word-header-txt");
      String? wordOfTheDayString = wordOfTheDayElement?.text;
      if (wordOfTheDayString != null) {
        print("word of the day: $wordOfTheDayString");
        return await searchWord(wordOfTheDayString);
      }
    } catch (e, stacktrace) {
      print('getArticleBody Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
    return null;
  }

  Future<LinkedHashMap<String, String>> getLanguageList() async {
    LinkedHashMap<String, String> languageMap = LinkedHashMap();
    try {
      final response =
          await dio.get("https://api.cognitive.microsofttranslator.com/languages?api-version=3.0");
      if (response.statusCode == 200) {
        Map<String, dynamic> json = response.data['translation'];
        json.forEach((key, value) {
          String name = value["name"];
          languageMap[name] = key;
        });
      } else {
        print("${response.statusCode}, ${response.data}");
      }
    } catch (e, stacktrace) {
      print('getLanguageList Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
    print(languageMap);
    return languageMap;
  }

  Future<Map<String, String>> translate(String text, {String? languageCode}) async {
    Map<String, String> map = {};
    try {
      String url = "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=en";
      if (languageCode != null && languageCode.isNotEmpty) {
        url += "&from=$languageCode";
      }
      var data = [
        {"Text": text}
      ];
      Options options = Options(
        contentType: Headers.jsonContentType,
        headers: {
          'Content-type': 'application/json',
          'Ocp-Apim-Subscription-Key': '92f53b5d87834dd399c6ab294d8f5cf7',
          'Ocp-Apim-Subscription-Region': 'uksouth'
        },
      );
      dio.interceptors.add(LogInterceptor(requestBody: true));
      final response = await dio.post(url, data: jsonEncode(data), options: options);
      if (response.statusCode == 200) {
        Map<String, dynamic> json = response.data[0];
        if (json.containsKey("detectedLanguage")) {
          String language = json["detectedLanguage"]["language"];
          map["detectedLanguage"] = language;
        }
        if (json.containsKey("translations")) {
          String result = json["translations"][0]["text"];
          map["translations"] = result;
        }
      } else {
        print("${response.statusCode}, ${response.data}");
      }
    } catch (e, stacktrace) {
      print('translate Exception: ' + e.toString());
      print('Stacktrace: ' + stacktrace.toString());
    }
    print(map);
    return map;
  }
}
