import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/utils/preference.dart';

class ForumThreadCubit extends Cubit<ForumThreadState> {
  String testText =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.";

  ForumThreadCubit() : super(ForumThreadState()) {
    //load data
    Comment comment = Comment(1, "Misaka", testText, DateTime.now().subtract(Duration(minutes: 15)));
    emit(state.copyWith(threadTitle: testText.substring(0, 20),
        threadBody: testText,
        threadAuthor: "Eren",
        threadLikes: 99,
        threadPostTime: DateTime.now().subtract(Duration(hours: 1)),
        comments: [comment]));
  }

  void toggleLikeThread() {
    emit(state.copyWith(likeThread: !state.likeThread,
        threadLikes: state.threadLikes + (state.likeThread ? -1 : 1)));
  }

  void toggleLikeComment(Comment comment) {
    List<int> likeComments = List.from(state.likeComments);
    if (likeComments.contains(comment.id)) {
      likeComments.remove(comment.id);
      comment.likes -= 1;
    } else {
      likeComments.add(comment.id);
      comment.likes += 1;
    }
    emit(state.copyWith(likeComments: likeComments));
  }

  void addComment(String body) {
    Comment comment = Comment(
        state.comments.length + 1, Preferences().username, body, DateTime.now());
    List<Comment> comments = List.from(state.comments);
    comments.add(comment);
    emit(state.copyWith(comments: comments));
  }
}

class ForumThreadState {
  String threadTitle;
  String threadBody;
  String threadAuthor;
  int threadLikes;
  bool likeThread;
  DateTime? threadPostTime;
  List<int> likeComments;
  List<Comment> comments;

  ForumThreadState({this.threadTitle = '',
    this.threadBody = '',
    this.threadAuthor = '',
    this.threadLikes = 0,
    this.threadPostTime,
    this.likeThread = false,
    this.likeComments = const [],
    this.comments = const []});

  ForumThreadState copyWith({String? threadTitle,
    String? threadBody,
    String? threadAuthor,
    DateTime? threadPostTime,
    int? threadLikes,
    bool? likeThread,
    List<int>? likeComments,
    List<Comment>? comments}) {
    return ForumThreadState(
      threadTitle: threadTitle ?? this.threadTitle,
      threadBody: threadBody ?? this.threadBody,
      threadAuthor: threadAuthor ?? this.threadAuthor,
      threadLikes: threadLikes ?? this.threadLikes,
      threadPostTime: threadPostTime ?? this.threadPostTime,
      likeThread: likeThread ?? this.likeThread,
      likeComments: likeComments ?? this.likeComments,
      comments: comments ?? this.comments,
    );
  }
}

class Comment {
  int id;
  String username;
  int likes;
  String body;
  DateTime commentPostTime;

  Comment(this.id, this.username, this.body, this.commentPostTime, {this.likes = 0});
}
