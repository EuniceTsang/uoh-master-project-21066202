import 'package:flutter_bloc/flutter_bloc.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(const TaskState());

  Future<void> changeTab(int currentIndex) async {
    if (currentIndex == state.currentTabIndex) {
      return;
    }
    emit(TaskState(currentTabIndex: currentIndex));
  }
}

class TaskState {
  final int currentTabIndex;

  const TaskState({this.currentTabIndex = 0});
}
