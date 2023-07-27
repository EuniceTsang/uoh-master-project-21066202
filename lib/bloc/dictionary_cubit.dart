import 'package:flutter_bloc/flutter_bloc.dart';

class DictionaryCubit extends Cubit<DictionaryState> {
  String word;
  String testText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";

  DictionaryCubit(this.word) : super(DictionaryState(searchingWord: word, isSearching: true)) {
    //load data
    if (word == "x") {
      return;
    }
    WordData wordData =
        WordData(word, "pof", "syllable", [testText, testText], [testText, testText]);
    emit(state.copyWith(wordData: wordData));
  }

  void clearSearching() {
    emit(state.copyWith(isSearching: false, searchingWord: ''));
  }

  void searchingWord(String word) {
    emit(state.copyWith(isSearching: word.isNotEmpty, searchingWord: word));
  }

  void performSearch() {
    WordData? wordData = state.wordData ??
        WordData(
            state.searchingWord, "pof", "syllable", [testText, testText], [testText, testText]);
    wordData.word = state.searchingWord;
    if (state.searchingWord == "x") {
      wordData = null;
    }
    emit(state.copyWith(wordData: wordData));
  }
}

class DictionaryState {
  final bool isSearching;
  final String searchingWord;
  final WordData? wordData;

  const DictionaryState({this.isSearching = false, this.searchingWord = '', this.wordData});

  DictionaryState copyWith({
    bool? isSearching,
    String? searchingWord,
    WordData? wordData,
  }) {
    return DictionaryState(
      isSearching: isSearching ?? this.isSearching,
      searchingWord: searchingWord ?? this.searchingWord,
      wordData: wordData ?? this.wordData,
    );
  }
}

class WordData {
  String word;
  String pof;
  String syllable;
  List<String> meanings;
  List<String> examples;

  WordData(this.word, this.pof, this.syllable, this.meanings, this.examples);
}
