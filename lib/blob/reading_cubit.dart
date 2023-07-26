import 'package:flutter_bloc/flutter_bloc.dart';

class ReadingCubit extends Cubit<ReadingState> {
  String url =
      'https://www.nytimes.com/images/2023/07/09/arts/09Byrd-Anniversary-illo/09Byrd-Anniversary-illo-blog427.jpg';
  String testText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n";

  ReadingCubit() : super(const ReadingState()) {
    //load data
    emit(state.copyWith(imageUrl: url, title: testText.substring(0, 20), body: testText * 10));
  }

  void selectWord(String word) {
    RegExp punctuationPattern = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
    word = word.replaceAll(punctuationPattern, '');
    emit(state.copyWith(selectedWord: word, isSelectingWord: true));
  }

  void clearSelectedWord() {
    emit(state.copyWith(selectedWord: '', isSelectingWord: false));
  }
}

class ReadingState {
  final String imageUrl;
  final String title;
  final String body;
  final String? selectedWord;
  final bool isSelectingWord;

  const ReadingState(
      {this.imageUrl = '',
      this.title = '',
      this.body = '',
      this.selectedWord,
      this.isSelectingWord = false});

  ReadingState copyWith({
    String? imageUrl,
    String? title,
    String? body,
    String? selectedWord,
    bool? isSelectingWord,
  }) {
    return ReadingState(
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      body: body ?? this.body,
      selectedWord: selectedWord ?? this.selectedWord,
      isSelectingWord: isSelectingWord ?? this.isSelectingWord,
    );
  }
}
