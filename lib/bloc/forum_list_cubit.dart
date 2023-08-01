import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/models/thread.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/service/repository.dart';
import 'package:source_code/utils/preference.dart';
import 'package:uuid/uuid.dart';

class ForumListCubit extends Cubit<ForumListState> {
  late FirebaseManager firebaseManager;
  late Repository repository;

  ForumListCubit(BuildContext context) : super(const ForumListState()) {
    //load data
    firebaseManager = context.read<FirebaseManager>();
    repository = context.read<Repository>();
    loadForumData();
  }

  void loadForumData() {
    firebaseManager.getThreadList().then((value) {
      repository.updateThread(value);
      emit(state.copyWith(newThreads: repository.allThreads, myThreads: repository.myThreads));
    });
  }

  void createThread(String title, String body) async{
    Thread thread = Thread(
        threadId: Uuid().v4(),
        title: title,
        body: body,
        postTime: DateTime.now(),
        likedUsers: [],
        userId: Preferences().uid);
    try {
      firebaseManager.createThread(thread);
      loadForumData();
    } on CustomException catch (e) {
      print(e);
    }
  }
}

class ForumListState {
  final List<Thread> allThreads;
  final List<Thread> myThreads;

  const ForumListState({this.allThreads = const [], this.myThreads = const []});

  ForumListState copyWith({
    List<Thread>? newThreads,
    List<Thread>? myThreads,
  }) {
    return ForumListState(
      allThreads: newThreads ?? this.allThreads,
      myThreads: myThreads ?? this.myThreads,
    );
  }
}
