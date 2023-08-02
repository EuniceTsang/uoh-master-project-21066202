import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:source_code/service/api_manager.dart';

class TranslationCubit extends Cubit<TranslationState> {
  late ApiManager apiManager;

  TranslationCubit(BuildContext context) : super(TranslationState()) {
    apiManager = context.read<ApiManager>();
    apiManager.getLanguageList().then((value) {
      LinkedHashMap<String, String> map = LinkedHashMap();
      map['Detect Language'] = '';
      map.addAll(value);
      emit(state.copyWith(languageMap: map, language: map.keys.first));
    });
  }

  void updateInputText(String text) {
    emit(state.copyWith(inputText: text));
  }

  Future<void> performTranslate() async {
    EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
    );
    String? languageCode = state.languageMap[state.language];
    Map result = await apiManager.translate(state.inputText, languageCode: languageCode);
    String detectedLanguage = '';
    String? translation;
    if (result.containsKey("detectedLanguage")) {
      for (var entry in state.languageMap.entries) {
        if (entry.value == result["detectedLanguage"]) {
          detectedLanguage = entry.key;
          break;
        }
      }
    }
    if (result.containsKey("translations")) {
      translation = result["translations"];
    }
    EasyLoading.dismiss();
    emit(state.copyWith(detectedLanguage: detectedLanguage, translatedText: translation));
  }

  void changeLanguage(String language) {
    emit(state.copyWith(language: language, detectedLanguage: ''));
  }
}

class TranslationState {
  final String inputText;
  final String translatedText;
  final LinkedHashMap<String, String> languageMap;
  final String language;
  final String detectedLanguage;

  TranslationState({
    this.inputText = '',
    this.translatedText = '',
    LinkedHashMap<String, String>? languageMap,
    this.language = 'Detect Language',
    this.detectedLanguage = '',
  }) : languageMap = languageMap ?? LinkedHashMap<String, String>();

  TranslationState copyWith({
    String? inputText,
    String? translatedText,
    LinkedHashMap<String, String>? languageMap,
    String? language,
    String? detectedLanguage,
  }) {
    return TranslationState(
      inputText: inputText ?? this.inputText,
      translatedText: translatedText ?? this.translatedText,
      language: language ?? this.language,
      languageMap: languageMap ?? this.languageMap,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
    );
  }
}
