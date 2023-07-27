import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(const HistoryState());

  Future<void> changeTab(int currentIndex) async {
    if (currentIndex == state.currentTabIndex) {
      return;
    }
    emit(HistoryState(currentTabIndex: currentIndex));
  }
}

class HistoryState {
  final int currentTabIndex;

  const HistoryState({this.currentTabIndex = 0});
}
