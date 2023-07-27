import 'package:flutter_bloc/flutter_bloc.dart';

class BaseNavigationCubit extends Cubit<BaseNavigationState> {
  BaseNavigationCubit() : super(const BaseNavigationState());

  Future<void> changeTab(int currentIndex) async {
    if (currentIndex == state.currentTabIndex) {
      return;
    }
    emit(BaseNavigationState(currentTabIndex: currentIndex));
  }
}

class BaseNavigationState {
 final int currentTabIndex;

  const BaseNavigationState({this.currentTabIndex = 0});
}
