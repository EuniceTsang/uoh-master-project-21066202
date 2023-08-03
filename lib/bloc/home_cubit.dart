import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/models/article.dart';
import 'package:source_code/models/thread.dart';
import 'package:source_code/models/user.dart';
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
    List<Word> wordHistory = await firebaseManager.getWordHistory();
    List<Thread> threads = await firebaseManager.getThreadList();
    List<Article> articles = await apiManager.getPopularArticles();
    Word? wordOfTheDay = await apiManager.getWordOfTheDay();
    AppUser? user = await firebaseManager.getUserData(FirebaseManager().uid);
    needReload = false;
    emit(state.copyWith(
        user: user,
        wordHistory: wordHistory.take(4).toList(),
        threads: threads.take(3).toList(),
        article: articles.isEmpty ? null : articles.first,
        wordOfTheDay: wordOfTheDay,
        loading: false));
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
  final Word? wordOfTheDay;
  final AppUser? user;
  final bool loading;

  const HomeState(
      {this.isSearching = false,
      this.searchingWord = '',
      this.wordHistory = const [],
      this.threads = const [],
      this.article,
      this.user,
      this.wordOfTheDay,
      this.loading = true});

  HomeState copyWith(
      {bool? isSearching,
      String? searchingWord,
      List<Word>? wordHistory,
      List<Thread>? threads,
      Article? article,
      Word? wordOfTheDay,
      AppUser? user,
      bool? needReload,
      bool? loading}) {
    return HomeState(
      isSearching: isSearching ?? this.isSearching,
      searchingWord: searchingWord ?? this.searchingWord,
      wordHistory: wordHistory ?? this.wordHistory,
      threads: threads ?? this.threads,
      article: article ?? this.article,
      user: user ?? this.user,
      wordOfTheDay: wordOfTheDay ?? this.wordOfTheDay,
      loading: loading ?? this.loading,
    );
  }
}
