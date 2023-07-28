import 'package:dio/dio.dart';
import 'package:source_code/models/word.dart';

class ApiManager {
  late final Dio dio;
  static const dictionaryApiKey = '2f75820c-65b7-4a16-94b9-71bdbd814b96';
  static const dictionaryUrl =
      'https://www.dictionaryapi.com/api/v3/references/learners/json/may?key=2f75820c-65b7-4a16-94b9-71bdbd814b96';

  ApiManager() {
    dio = Dio();
  }

  Future<Word?> searchWord(String word) async {
    try {
      final response = await dio.get(
          'https://www.dictionaryapi.com/api/v3/references/learners/json/$word?key=$dictionaryApiKey');
      if (response.statusCode == 200) {
        Word? wordObj =  Word.fromJson(word, response.data);
        return wordObj;
      } else {
        print("${response.statusCode}, ${response.data}");
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
