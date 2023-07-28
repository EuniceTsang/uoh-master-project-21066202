class Word {
  String word;
  String syllable;
  String? audioUrl;
  Map<String, List<Definition>> posDefinitionMap;

  Word({
    required this.word,
    required this.syllable,
    this.audioUrl,
    required this.posDefinitionMap,
  });

  static Word? fromJson(String word, List<dynamic> json) {
    String? _syllable;
    String? _audioUrl;
    Map<String, List<Definition>> _posDefinitionMap = {};
    json.forEach((wordJson) {
      String? _pos;
      String hw = wordJson['hwi']['hw'].replaceAll(RegExp(r'[^a-zA-Z]'), '');   //remove all non-alphabetic characters
      if (hw.toLowerCase() != word.toLowerCase()) {
        return;
      }
      Map prs = wordJson["hwi"]["prs"][0];
      if (_syllable == null) {
        _syllable = prs["ipa"];
      }
      if (prs.containsKey("sound") && _audioUrl == null) {
        String audioFileName = prs["sound"]["audio"];
        _audioUrl =
            "https://media.merriam-webster.com/audio/prons/en/us/mp3/${getAudioSubdirectory(audioFileName)}/$audioFileName.mp3";
      }
      _pos = wordJson["fl"];
      _posDefinitionMap[_pos!] = [];
      List<dynamic> definitions = wordJson["def"][0]["sseq"];
      definitions.forEach((definitionJson) {
        List dt = definitionJson[0][1]["dt"];
        String? _definition;
        List<String> _sentences = [];
        dt.forEach((element) {
          if(_definition != null && _sentences.isNotEmpty){
            return;
          }
          if(element[0] == "text"){
            _definition = element[1];
          }
          else if (element[0] == "vis"){
            List<dynamic> sentenceJsonList = element[1];
            sentenceJsonList.forEach((sentenceJson) {
              String sentence = sentenceJson["t"];
              _sentences.add(sentence);
            });
          }
        });
        Definition definition = Definition(definition: _definition!, sentences: _sentences);
        List<Definition> definitions = _posDefinitionMap[_pos!]!;
        definitions.add(definition);
        _posDefinitionMap[_pos] = definitions;
      });
    });
    if (_posDefinitionMap.isNotEmpty && _syllable != null) {
      return Word(
          word: word,
          syllable: _syllable!,
          posDefinitionMap: _posDefinitionMap,
          audioUrl: _audioUrl);
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
}

class Definition {
  String definition;
  List<String> sentences;

  Definition({
    required this.definition,
    required this.sentences,
  });
}
