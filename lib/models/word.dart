import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:source_code/utils/preference.dart';
import 'package:source_code/utils/utils.dart';

part 'word.g.dart';

@JsonSerializable()
class Word {
  @JsonKey(name: WordFields.word)
  String word;

  @JsonKey(name: WordFields.user_id)
  String userId;

  @JsonKey(name: WordFields.search_time, fromJson: DateTime.parse, toJson: Utils.dateTimeToString)
  DateTime searchTime;

  @JsonKey(ignore: true)
  String syllable;

  @JsonKey(ignore: true)
  String? audioUrl;

  @JsonKey(ignore: true)
  Map<String, List<Definition>> posDefinitionMap;

  @JsonKey(ignore: true)
  String? shortDefinition;

  @JsonKey(ignore: true)
  String? shortDefinitionPos;

  Word({
    required this.word,
    required this.userId,
    required this.searchTime,
    this.syllable = '',
    this.audioUrl,
    this.posDefinitionMap = const {},
    this.shortDefinition,
    this.shortDefinitionPos,
  });

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  Map<String, dynamic> toJson() => _$WordToJson(this);

  static Word? parseFromApi(String word, List<dynamic> json) {
    String? _syllable;
    String? _audioUrl;
    Map<String, List<Definition>> _posDefinitionMap = {};
    String? _shortDefinition, _shortDefinitionPos;
    json.forEach((wordJson) {
      try {
        String? _pos;
        //remove all non-alphabetic characters
        String hw = wordJson['hwi']['hw'].replaceAll(RegExp(r'[^a-zA-Z]'), '');
        if (hw.toLowerCase() != word.toLowerCase()) {
          return;
        }
        dynamic hwi = wordJson["hwi"];
        Map prs;
        if (hwi.containsKey("prs")) {
          prs = hwi["prs"][0];
        } else if (hwi.containsKey("altprs")) {
          prs = hwi["altprs"][0];
        } else {
          return;
        }
        if (_syllable == null) {
          _syllable = prs["ipa"];
        }
        if (prs.containsKey("sound") && _audioUrl == null) {
          String audioFileName = prs["sound"]["audio"];
          _audioUrl =
              "https://media.merriam-webster.com/audio/prons/en/us/mp3/${getAudioSubdirectory(audioFileName)}/$audioFileName.mp3";
        }
        _pos = wordJson["fl"];
        if (_shortDefinitionPos == null &&
            _shortDefinition == null &&
            wordJson.containsKey("shortdef")) {
          _shortDefinitionPos = _pos;
          List<String> shortdefList = wordJson["shortdef"].whereType<String>().toList();
          _shortDefinition = shortdefList.join(", ").replaceAll("—", "");
        }
        _posDefinitionMap[_pos!] = [];
        List<dynamic> definitions = wordJson["def"][0]["sseq"];
        definitions.forEach((definitionJson) {
          List dt = definitionJson[0][1]["dt"];
          String? _definition;
          List<String> _sentences = [];
          dt.forEach((element) {
            if (_definition != null && _sentences.isNotEmpty) {
              return;
            }
            if (element[0] == "text") {
              //remove curly brackets and the content inside them
              _definition = element[1].replaceAll(RegExp(r'\{.*?\}'), '');
              _definition = toBeginningOfSentenceCase(_definition)!;
            } else if (element[0] == "vis") {
              List<dynamic> sentenceJsonList = element[1];
              sentenceJsonList.forEach((sentenceJson) {
                String sentence =
                    sentenceJson["t"].replaceAll("{it}", "<i>").replaceAll("{/it}", "</i>");
                //remove curly brackets and the content inside them
                sentence = sentence.replaceAll(RegExp(r'\{.*?\}'), '');
                _sentences.add(toBeginningOfSentenceCase(sentence)!);
              });
            }
          });
          if (_definition == null || _definition!.isEmpty) {
            return;
          }
          Definition definition = Definition(definition: _definition!, sentences: _sentences);
          List<Definition> definitions = _posDefinitionMap[_pos!]!;
          definitions.add(definition);
          _posDefinitionMap[_pos] = definitions;
        });
      } catch (e, stacktrace) {
        print("Word.parseFromApi: $e");
        print(stacktrace);
        return;
      }
    });
    if (_posDefinitionMap.isNotEmpty && _syllable != null) {
      return Word(
          userId: Preferences().uid,
          searchTime: DateTime.now(),
          word: word,
          syllable: _syllable!,
          posDefinitionMap: _posDefinitionMap,
          audioUrl: _audioUrl,
          shortDefinitionPos: _shortDefinitionPos,
          shortDefinition: _shortDefinition);
    } else {
      return null;
    }
  }

  static String getAudioSubdirectory(String audioFileName) {
    if (audioFileName.startsWith('bix')) {
      return 'bix';
    } else if (audioFileName.startsWith('gg')) {
      return 'gg';
    } else if (RegExp(r'^[0-9_]').hasMatch(audioFileName)) {
      return 'number';
    } else {
      return audioFileName.substring(0, 1);
    }
  }

  @override
  String toString() {
    return 'Word: $word, Syllable: $syllable, Audio URL: $audioUrl, Definitions: $posDefinitionMap';
  }
}

class Definition {
  String definition;
  List<String> sentences;

  Definition({
    required this.definition,
    required this.sentences,
  });

  @override
  String toString() {
    return 'Definition: $definition, Sentences: $sentences, ';
  }
}

class WordFields {
  static const collection = 'word';
  static const word = 'word';
  static const search_time = 'search_time';
  static const user_id = 'user_id';
}
