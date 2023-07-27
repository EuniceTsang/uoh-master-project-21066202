import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/utils/preference.dart';

class ForumListCubit extends Cubit<ForumListState> {
  String testText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";

  ForumListCubit() : super(const ForumListState()) {
    //load data
    Thread thread = Thread(
        testText.substring(0, 20), "Eren", DateTime.now().subtract(Duration(days: 1)),
        likes: 100, comments: 100);
    List<Thread> threads = [];
    for (int i = 0; i < 20; i++) {
      threads.add(thread);
    }
    emit(state.copyWith(newThreads: threads));
  }

  void createThread(String title, String body){
    Thread thread = Thread(title, Preferences().username, DateTime.now());
    List<Thread> newThreads = List.from(state.newThreads);
    List<Thread> myThreads = List.from(state.myThreads);
    newThreads.add(thread);
    myThreads.add(thread);

    newThreads.sort((a, b) => b.postTime.compareTo(a.postTime));
    myThreads.sort((a, b) => b.postTime.compareTo(a.postTime));

    emit(state.copyWith(newThreads: newThreads, myThreads: myThreads));
  }
}

class ForumListState {
  final List<Thread> newThreads;
  final List<Thread> myThreads;

  const ForumListState({this.newThreads = const [], this.myThreads = const []});

  ForumListState copyWith({
    List<Thread>? newThreads,
    List<Thread>? myThreads,
  }) {
    return ForumListState(
      newThreads: newThreads ?? this.newThreads,
      myThreads: myThreads ?? this.myThreads,
    );
  }
}

class Thread {
  String title;
  String author;
  int comments;
  int likes;
  DateTime postTime;

  Thread(this.title, this.author, this.postTime, {this.comments = 0, this.likes = 0});
}
