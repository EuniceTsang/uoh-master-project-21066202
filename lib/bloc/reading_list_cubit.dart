import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/models/article.dart';
import 'package:source_code/service/api_manager.dart';
import 'package:source_code/service/firebase_manager.dart';

class ReadingListCubit extends Cubit<ReadingListState> {
  late FirebaseManager firebaseManager;
  late ApiManager apiManager;

  ReadingListCubit(BuildContext context) : super(const ReadingListState()) {
    firebaseManager = context.read<FirebaseManager>();
    apiManager = context.read<ApiManager>();
    getArticles();
  }

  Future<void> getArticles({String? keyword}) async {
    Trace customTrace = FirebasePerformance.instance.newTrace('reading-list-screen-loading');
    await customTrace.start();
    emit(state.copyWith(loading: true));
    List<Article> articles = [];
    if (keyword == null) {
      articles = await apiManager.getPopularArticles();
    } else {
      articles = await apiManager.searchArticles(keyword);
    }
    emit(state.copyWith(articles: articles, loading: false));
    await customTrace.stop();
  }

  void clearSearching() {
    emit(state.copyWith(isSearching: false, searchingWord: ''));
  }

  void searchingWord(String word) {
    emit(state.copyWith(isSearching: word.isNotEmpty, searchingWord: word));
  }
}

class ReadingListState {
  final bool isSearching;
  final String searchingWord;
  final List<Article> articles;
  final bool loading;

  const ReadingListState(
      {this.isSearching = false, this.searchingWord = '', this.articles = const [], this.loading = true});

  ReadingListState copyWith({bool? isSearching, String? searchingWord, List<Article>? articles, bool? loading}) {
    return ReadingListState(
      isSearching: isSearching ?? this.isSearching,
      searchingWord: searchingWord ?? this.searchingWord,
      articles: articles ?? this.articles,
      loading: loading ?? this.loading
    );
  }
}
