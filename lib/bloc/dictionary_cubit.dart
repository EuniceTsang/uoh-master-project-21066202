import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:source_code/models/word.dart';
import 'package:source_code/service/api_manager.dart';
import 'package:source_code/service/firebase_manager.dart';

class DictionaryCubit extends Cubit<DictionaryState> {
  late final FirebaseManager firebaseManager;
  late final ApiManager apiManager;
  AudioPlayer audioPlayer = AudioPlayer();
  String word;

  DictionaryCubit(BuildContext context, this.word)
      : super(DictionaryState(searchingWord: word, isSearching: true, isLoading: true)) {
    apiManager = context.read<ApiManager>();
    firebaseManager = context.read<FirebaseManager>();
    performSearch();
  }

  Future<void> performSearch() async {
    EasyLoading.show();
    emit(state.copyWith(isLoading: true));
    Word? wordData = await apiManager.searchWord(state.searchingWord.toLowerCase());
    if (wordData != null) {
      await firebaseManager.updateWord(wordData);
    }
    EasyLoading.dismiss();
    emit(state.copyWith(isLoading: false, wordData: wordData));
  }

  void playAudio() {
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
