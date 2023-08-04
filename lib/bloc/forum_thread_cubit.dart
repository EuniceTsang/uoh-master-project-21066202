import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/models/comment.dart';
import 'package:source_code/models/task.dart';
import 'package:source_code/models/thread.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/service/task_manager.dart';
import 'package:source_code/utils/preference.dart';
import 'package:uuid/uuid.dart';

class ForumThreadCubit extends Cubit<ForumThreadState> {
  Thread? thread;
  late BuildContext context;
  late FirebaseManager firebaseManager;
  late final TaskManager taskManager;

  ForumThreadCubit(BuildContext context, Thread? thread)
      : super(ForumThreadState(thread: thread!)) {
    this.context = context;
    this.thread = thread;
    firebaseManager = context.read<FirebaseManager>();
    taskManager = context.read<TaskManager>();
    //load data
    if (thread != null) {
      loadThreadData();
    }
  }

  Future<void> loadThreadData() async {
    List<Comment> comments = await firebaseManager.getComments(thread!.threadId);
    emit(state.copyWith(thread: thread, comments: comments, loading: false));
  }

  void toggleLikeThread() {
    Thread thread = state.thread;
    List<String> likeUsers = thread.likedUsers;
    String uid = Preferences().uid;
    if (likeUsers.contains(uid)) {
      likeUsers.remove(uid);
    } else {
      likeUsers.add(uid);
    }
    thread.likedUsers = likeUsers;
    firebaseManager.toggleLikeThread(thread).then((value) => loadThreadData());
  }

  void toggleLikeComment(Comment comment) {
    List<String> likeUsers = comment.likedUsers;
    String uid = Preferences().uid;
    if (likeUsers.contains(uid)) {
      likeUsers.remove(uid);
    } else {
      likeUsers.add(uid);
    }
    comment.likedUsers = likeUsers;
    firebaseManager.toggleLikeComment(comment).then((value) => loadThreadData());
  }

  void addComment(String body) async {
    Comment comment = Comment(
        commentId: Uuid().v4(),
        userId: Preferences().uid,
        body: body,
        postTime: DateTime.now(),
        likedUsers: [],
        threadId: thread!.threadId);
    await firebaseManager.addComment(comment);
    await loadThreadData();
    await taskManager.checkTasksAchieve([TaskType.ReplyInForum]);
  }
}

class ForumThreadState {
  Thread thread;
  List<Comment> comments;
  final bool loading;

  ForumThreadState({required this.thread, this.comments = const [], this.loading = true});

  ForumThreadState copyWith({Thread? thread, List<Comment>? comments, bool? loading}) {
    return ForumThreadState(
      thread: thread ?? this.thread,
      comments: comments ?? this.comments,
      loading: loading ?? this.loading,
    );
  }
}
