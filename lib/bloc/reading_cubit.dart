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
    String? htmlContent = await apiManager.getHtml(article.url);
    dom.Document document = parse(htmlContent);
    dom.Element? articleBody = findSectionTag(document.body, "articleBody");
    String? articleBodyHtml = articleBody?.outerHtml;
    String? body;
    if (articleBodyHtml != null) {
      body = extractParagraphText(articleBodyHtml);
    }
    EasyLoading.dismiss();
    emit(state.copyWith(article: article, body: body));
  }

  dom.Element? findSectionTag(dom.Element? element, String sectionName) {
    if (element != null) {
      // if (element.localName == 'section') {
      //   print(element.attributes);
      // }
      if (element.localName == 'section' && element.attributes['name'] == sectionName) {
        return element;
      } else {
        for (var child in element.children) {
          var foundTag = findSectionTag(child, sectionName);
          if (foundTag != null) {
            return foundTag;
          }
        }
      }
    }
    return null;
  }

  String extractParagraphText(String html) {
    dom.Document document = parse(html);
    List<dom.Element> paragraphs = document.getElementsByTagName('p');
    String result = '';
    for (dom.Element paragraph in paragraphs) {
      result += "${paragraph.text}\n";
    }
    return result;
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
