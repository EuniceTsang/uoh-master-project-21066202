import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:source_code/models/article.dart';
import 'package:source_code/service/api_manager.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

class ReadingCubit extends Cubit<ReadingState> {
  late final FirebaseManager firebaseManager;
  late final ApiManager apiManager;

  ReadingCubit(BuildContext context, Article? article) : super(const ReadingState()) {
    apiManager = context.read<ApiManager>();
    firebaseManager = context.read<FirebaseManager>();
    EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
    );
    if (article != null) {
      loadArticle(article).then((value) {
        if (state.body?.isNotEmpty == true) {
          article.searchTime = DateTime.now();
          firebaseManager.updateArticleHistory(article);
        }
      });
    }
  }

  Future<void> loadArticle(Article article) async {
    String? body = await apiManager.getArticleBody(article);
    EasyLoading.dismiss();
    emit(state.copyWith(article: article, body: body));
  }

  void selectWord(String word) {
    RegExp alphabetPattern = RegExp(r'[^a-zA-Z]');
    word = word.replaceAll(alphabetPattern, '').toLowerCase();
    if (word.isEmpty) {
      return;
    }
    emit(state.copyWith(selectedWord: word, isSelectingWord: true));
  }

  void clearSelectedWord() {
    emit(state.copyWith(selectedWord: '', isSelectingWord: false));
  }
}

class ReadingState {
  final Article? article;
  final String? body;
  final String? selectedWord;
  final bool isSelectingWord;

  const ReadingState({this.article, this.body, this.selectedWord, this.isSelectingWord = false});

  ReadingState copyWith({
    Article? article,
    String? body,
    String? selectedWord,
    bool? isSelectingWord,
  }) {
    return ReadingState(
      article: article ?? this.article,
      body: body ?? this.body,
      selectedWord: selectedWord ?? this.selectedWord,
      isSelectingWord: isSelectingWord ?? this.isSelectingWord,
    );
  }
}
