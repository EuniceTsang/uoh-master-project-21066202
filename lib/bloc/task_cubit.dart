import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/models/task.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/service/task_manager.dart';

class TaskCubit extends Cubit<TaskState> {
  late FirebaseManager firebaseManager;
  late TaskManager taskManager;

  TaskCubit(BuildContext context) : super(const TaskState()) {
    firebaseManager = context.read<FirebaseManager>();
    taskManager = context.read<TaskManager>();
    loadTasks();
  }

  Future<void> loadTasks() async {
    Trace customTrace = FirebasePerformance.instance.newTrace('task-screen-loading');
    await customTrace.start();
    await taskManager.loadTask();
    emit(state.copyWith(
        currentTasks: taskManager.currentTasks, completedTasks: taskManager.completedTasks, loading: false));
    await customTrace.stop();
  }
}

class TaskState {
  final List<Task> currentTasks;
  final List<Task> completedTasks;
  final bool loading;

  const TaskState(
      {this.currentTasks = const [], this.completedTasks = const [], this.loading = true});


  TaskState copyWith({
    List<Task>? currentTasks,
    List<Task>? completedTasks,
    bool? loading
  }) {
    return TaskState(
      currentTasks: currentTasks ?? this.currentTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      loading: loading ?? this.loading,
    );
  }

}
