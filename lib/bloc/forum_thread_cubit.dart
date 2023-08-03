import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/models/comment.dart';
import 'package:source_code/models/thread.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/service/repository.dart';
import 'package:source_code/utils/preference.dart';
import 'package:uuid/uuid.dart';

class ForumThreadCubit extends Cubit<ForumThreadState> {
  Thread? thread;
  late BuildContext context;
  late FirebaseManager firebaseManager;

  ForumThreadCubit(BuildContext context, Thread? thread)
      : super(ForumThreadState(thread: thread!)) {
    this.context = context;
    this.thread = thread;
    firebaseManager = context.read<FirebaseManager>();
    //load data
    if (thread != null) {
      loadThreadData();
    }
  }

  Future<void> loadThreadData() async {
    List<Comment> comments = await firebaseManager.getComments(thread!.threadId);
    emit(state.copyWith(thread: thread, comments: comments));
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

  void addComment(String body) {
    Comment comment = Comment(
        commentId: Uuid().v4(),
        userId: Preferences().uid,
        body: body,
        postTime: DateTime.now(),
        likedUsers: [],
        threadId: thread!.threadId);
    firebaseManager.addComment(comment).then((value) => loadThreadData());
  }
}

class ForumThreadState {
  Thread thread;
  List<Comment> comments;

  ForumThreadState({required this.thread, this.comments = const []});

  ForumThreadState copyWith({Thread? thread, List<Comment>? comments}) {
    return ForumThreadState(
      thread: thread ?? this.thread,
      comments: comments ?? this.comments,
    );
  }
}
