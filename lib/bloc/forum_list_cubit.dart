import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/models/thread.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/service/task_manager.dart';
import 'package:source_code/utils/preference.dart';
import 'package:uuid/uuid.dart';

import '../models/task.dart';

class ForumListCubit extends Cubit<ForumListState> {
  late FirebaseManager firebaseManager;
  late final TaskManager taskManager;
  bool needReload = false;

  ForumListCubit(BuildContext context) : super(const ForumListState()) {
    firebaseManager = context.read<FirebaseManager>();
    taskManager = context.read<TaskManager>();
    //load data
    loadForumData();
  }

  Future<void> loadForumData() async {
    List<Thread> allThreadList = await firebaseManager.getThreadList();
    List<Thread> myThreadList =
        allThreadList.where((element) => element.userId == Preferences().uid).toList();
    emit(state.copyWith(newThreads: allThreadList, myThreads: myThreadList, loading: false));
  }

  void createThread(String title, String body) async {
    Thread thread = Thread(
        threadId: Uuid().v4(),
        title: title,
        body: body,
        postTime: DateTime.now(),
        likedUsers: [],
        userId: Preferences().uid);
    try {
      await firebaseManager.createThread(thread);
      await loadForumData();
      await taskManager.checkTasksAchieve([TaskType.PostInForum]);
    } on CustomException catch (e) {
      print(e);
    }
  }
}

class ForumListState {
  final List<Thread> allThreads;
  final List<Thread> myThreads;
  final bool loading;

  const ForumListState(
      {this.allThreads = const [], this.myThreads = const [], this.loading = true});

  ForumListState copyWith({List<Thread>? newThreads, List<Thread>? myThreads, bool? loading}) {
    return ForumListState(
      allThreads: newThreads ?? this.allThreads,
      myThreads: myThreads ?? this.myThreads,
      loading: loading ?? this.loading,
    );
  }
}
