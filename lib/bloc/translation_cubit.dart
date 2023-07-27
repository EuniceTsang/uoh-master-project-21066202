import 'package:flutter_bloc/flutter_bloc.dart';

class TranslationCubit extends Cubit<TranslationState> {
  TranslationCubit() : super(const TranslationState());

  void updateInputText(String text) {
    emit(state.copyWith(inputText: text));
  }

  void performTranslate() {}

  void changeLanguage(String language) {
    emit(state.copyWith(language: language));
  }
}

class TranslationState {
  final String inputText;
  final String translatedText;
  final String? language;

  const TranslationState({this.inputText = '', this.translatedText = '', this.language});

  TranslationState copyWith({
    String? inputText,
    String? translatedText,
    String? language,
  }) {
    return TranslationState(
      inputText: inputText ?? this.inputText,
      translatedText: translatedText ?? this.translatedText,
      language: language ?? this.language,
    );
  }
}
