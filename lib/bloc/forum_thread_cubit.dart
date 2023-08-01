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
  late Repository repository;

  ForumThreadCubit(BuildContext context, Thread? thread) : super(ForumThreadState(thread: thread!)) {
    this.context = context;
    this.thread = thread;
    firebaseManager = context.read<FirebaseManager>();
    repository = context.read<Repository>();
    //load data
    if (thread != null) {
      loadThreadData();
    }
  }

  void loadThreadData() {
    firebaseManager.getComments(thread!.threadId).then((value) {
      emit(state.copyWith(thread: thread, comments: value));
    });
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
    emit(state.copyWith(thread: thread));
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
    emit(state);
  }

  void addComment(String body) {
    Comment comment = Comment(
        commentId: Uuid().v4(),
        userId: Preferences().uid,
        body: body,
        postTime: DateTime.now(),
        likedUsers: [],
        threadId: thread!.threadId);
    List<Comment> comments = List.from(state.comments);
    comments.add(comment);
    comments.sort((a, b) => b.postTime.compareTo(a.postTime));
    emit(state.copyWith(comments: comments));
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
