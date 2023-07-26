import 'package:flutter_bloc/flutter_bloc.dart';

class ForumListCubit extends Cubit<ForumListState> {
  ForumListCubit() : super(const ForumListState());

  Future<void> changeTab(int currentIndex) async {
    if (currentIndex == state.currentTabIndex) {
      return;
    }
    emit(ForumListState(currentTabIndex: currentIndex));
  }
}

class ForumListState {
  final int currentTabIndex;

  const ForumListState({this.currentTabIndex = 0});
}
