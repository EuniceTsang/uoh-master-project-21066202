import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/models/thread.dart';
import 'package:source_code/models/word.dart';
import 'package:source_code/service/firebase_manager.dart';

class HomeCubit extends Cubit<HomeState> {
  late FirebaseManager firebaseManager;

  HomeCubit(BuildContext context) : super(const HomeState()) {
    firebaseManager = context.read<FirebaseManager>();
    loadData();
  }

  Future<void> loadData() async {
    List<Word> wordHistory = await firebaseManager.getWords();
    List<Thread> threads = await firebaseManager.getThreadList();
    emit(state.copyWith(
        wordHistory: wordHistory.take(4).toList(), threads: threads.take(3).toList()));
  }

  void clearSearching() {
    emit(state.copyWith(isSearching: false, searchingWord: ''));
  }

  void searchingWord(String word) {
    emit(state.copyWith(isSearching: word.isNotEmpty, searchingWord: word));
  }
}

class HomeState {
  final bool isSearching;
  final String searchingWord;
  final List<Word> wordHistory;
  final List<Thread> threads;

  const HomeState(
      {this.isSearching = false,
      this.searchingWord = '',
      this.wordHistory = const [],
      this.threads = const []});

  HomeState copyWith({
    bool? isSearching,
    String? searchingWord,
    List<Word>? wordHistory,
    List<Thread>? threads,
  }) {
    return HomeState(
      isSearching: isSearching ?? this.isSearching,
      searchingWord: searchingWord ?? this.searchingWord,
      wordHistory: wordHistory ?? this.wordHistory,
      threads: threads ?? this.threads,
    );
  }
}
