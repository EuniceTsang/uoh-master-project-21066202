import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:source_code/models/article.dart';
import 'package:source_code/models/task.dart';
import 'package:source_code/service/api_manager.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/service/task_manager.dart';

class ReadingCubit extends Cubit<ReadingState> {
  late final FirebaseManager firebaseManager;
  late final ApiManager apiManager;
  late final TaskManager taskManager;

  ReadingCubit(BuildContext context, Article? article) : super(const ReadingState()) {
    apiManager = context.read<ApiManager>();
    firebaseManager = context.read<FirebaseManager>();
    taskManager = context.read<TaskManager>();
    taskManager.resetWordCheckedInArticle();
    EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
    );
    if (article != null) {
      loadArticle(article).then((value) async {
        if (state.body?.isNotEmpty == true) {
          article.searchTime = DateTime.now();
          bool isNewArticle = await firebaseManager.updateArticleHistory(article);
          List<TaskType> checkTaskType = [TaskType.ConsistentReading];
          if (isNewArticle) {
            checkTaskType.add(TaskType.Reading);
          }
          taskManager.checkTasksAchieve(checkTaskType);
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
