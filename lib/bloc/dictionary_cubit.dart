import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:source_code/models/word.dart';
import 'package:source_code/service/api_manager.dart';

class DictionaryCubit extends Cubit<DictionaryState> {
  late final ApiManager apiManager;
  AudioPlayer audioPlayer = AudioPlayer();
  String word;
  String testText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";

  DictionaryCubit(BuildContext context, this.word)
      : super(DictionaryState(searchingWord: word, isSearching: true, isLoading: true)) {
    apiManager = context.read<ApiManager>();
    performSearch();
  }

  void performSearch(){
    EasyLoading.show();
    emit(state.copyWith(isLoading: true));
    apiManager.searchWord(state.searchingWord.toLowerCase()).then((wordData) {
      EasyLoading.dismiss();
      emit(state.copyWith(isLoading: false, wordData: wordData));
    });
  }

  void playAudio(){
    audioPlayer.play(UrlSource(state.wordData!.audioUrl!));
  }

  void clearSearching() {
    emit(state.copyWith(isSearching: false, searchingWord: ''));
  }

  void searchingWord(String word) {
    emit(state.copyWith(isSearching: word.isNotEmpty, searchingWord: word));
  }
}

class DictionaryState {
  final bool isLoading;
  final bool isSearching;
  final String searchingWord;
  final Word? wordData;

  const DictionaryState(
      {this.isLoading = false, this.isSearching = false, this.searchingWord = '', this.wordData});

  DictionaryState copyWith({
    bool? isLoading,
    bool? isSearching,
    String? searchingWord,
    Word? wordData,
  }) {
    return DictionaryState(
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      searchingWord: searchingWord ?? this.searchingWord,
      wordData: wordData ?? this.wordData,
    );
  }
}

