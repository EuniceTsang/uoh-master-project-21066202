import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
    List<Article> articles = [];
    if (keyword == null) {
      articles = await apiManager.getPopularArticles();
    } else {
      articles = await apiManager.searchArticles(keyword);
    }
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    emit(state.copyWith(articles: articles));
  }

  void clearSearching() {
    emit(state.copyWith(isSearching: false, searchingWord: ''));
  }

  void searchingWord(String word) {
    emit(state.copyWith(isSearching: word.isNotEmpty, searchingWord: word));
  }

  void performSearch() {
    EasyLoading.show();
    getArticles(keyword: state.searchingWord);
  }
}

class ReadingListState {
  final bool isSearching;
  final String searchingWord;
  final List<Article> articles;

  const ReadingListState(
      {this.isSearching = false, this.searchingWord = '', this.articles = const []});

  ReadingListState copyWith({bool? isSearching, String? searchingWord, List<Article>? articles}) {
    return ReadingListState(
      isSearching: isSearching ?? this.isSearching,
      searchingWord: searchingWord ?? this.searchingWord,
      articles: articles ?? this.articles,
    );
  }
}
