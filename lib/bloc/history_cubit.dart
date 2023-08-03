import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/models/article.dart';
import 'package:source_code/models/word.dart';
import 'package:source_code/service/firebase_manager.dart';

class HistoryCubit extends Cubit<HistoryState> {
  late final FirebaseManager firebaseManager;

  HistoryCubit(BuildContext context) : super(const HistoryState()) {
    firebaseManager = context.read<FirebaseManager>();
    loadHistory();
  }

  Future<void> loadHistory() async {
    List<Word> wordHistory = await firebaseManager.getWordHistory();
    List<Article> articleHistory = await firebaseManager.getArticleHistory();
    emit(state.copyWith(wordHistory: wordHistory, articleHistory: articleHistory, loading: false));
  }
}

class HistoryState {
  final List<Word> wordHistory;
  final List<Article> articleHistory;
  final bool loading;

  const HistoryState(
      {this.wordHistory = const [], this.articleHistory = const [], this.loading = true});

  HistoryState copyWith({List<Word>? wordHistory, List<Article>? articleHistory, bool? loading}) {
    return HistoryState(
      wordHistory: wordHistory ?? this.wordHistory,
      articleHistory: articleHistory ?? this.articleHistory,
      loading: loading ?? this.loading,
    );
  }
}
