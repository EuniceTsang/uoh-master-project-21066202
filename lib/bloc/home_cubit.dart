import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/models/article.dart';
import 'package:source_code/models/thread.dart';
import 'package:source_code/models/word.dart';
import 'package:source_code/service/api_manager.dart';
import 'package:source_code/service/firebase_manager.dart';

class HomeCubit extends Cubit<HomeState> {
  late FirebaseManager firebaseManager;
  late ApiManager apiManager;
  bool needReload = false;

  HomeCubit(BuildContext context) : super(const HomeState()) {
    firebaseManager = context.read<FirebaseManager>();
    apiManager = context.read<ApiManager>();
    loadData();
  }

  Future<void> loadData() async {
    List<Word> wordHistory = await firebaseManager.getWords();
    List<Thread> threads = await firebaseManager.getThreadList();
    List<Article> articles = await apiManager.getPopularArticles();
    emit(state.copyWith(
        wordHistory: wordHistory.take(4).toList(),
        threads: threads.take(3).toList(),
        article: articles.isEmpty ? null : articles.first));
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
  final Article? article;

  const HomeState(
      {this.isSearching = false,
      this.searchingWord = '',
      this.wordHistory = const [],
      this.threads = const [],
      this.article});

  HomeState copyWith({
    bool? isSearching,
    String? searchingWord,
    List<Word>? wordHistory,
    List<Thread>? threads,
    Article? article,
  }) {
    return HomeState(
      isSearching: isSearching ?? this.isSearching,
      searchingWord: searchingWord ?? this.searchingWord,
      wordHistory: wordHistory ?? this.wordHistory,
      threads: threads ?? this.threads,
      article: article ?? this.article,
    );
  }
}
