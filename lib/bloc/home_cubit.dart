import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void clearSearching(){
    emit(state.copyWith(isSearching: false, searchingWord: ''));
  }

  void searchingWord(String word){
    emit(state.copyWith(isSearching: word.isNotEmpty, searchingWord: word));
  }

  void performSearch(){

  }
}

class HomeState {
  final bool isSearching;
  final String searchingWord;

  const HomeState({this.isSearching = false, this.searchingWord = ''});

  HomeState copyWith({
    bool? isSearching,
    String? searchingWord,
  }) {
    return HomeState(
      isSearching: isSearching ?? this.isSearching,
      searchingWord: searchingWord ?? this.searchingWord,
    );
  }
}
