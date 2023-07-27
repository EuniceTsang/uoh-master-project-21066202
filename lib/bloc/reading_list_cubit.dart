import 'package:flutter_bloc/flutter_bloc.dart';

class ReadingListCubit extends Cubit<ReadingListState> {
  ReadingListCubit() : super(const ReadingListState());

  void clearSearching() {
    emit(state.copyWith(isSearching: false, searchingWord: ''));
  }

  void searchingWord(String word) {
    emit(state.copyWith(isSearching: word.isNotEmpty, searchingWord: word));
  }

  void performSearch() {}
}

class ReadingListState {
  final bool isSearching;
  final String searchingWord;

  const ReadingListState({this.isSearching = false, this.searchingWord = ''});

  ReadingListState copyWith({
    bool? isSearching,
    String? searchingWord,
  }) {
    return ReadingListState(
      isSearching: isSearching ?? this.isSearching,
      searchingWord: searchingWord ?? this.searchingWord,
    );
  }
}
