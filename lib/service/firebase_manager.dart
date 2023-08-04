import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:source_code/models/article.dart';
import 'package:source_code/models/comment.dart';
import 'package:source_code/models/task.dart';
import 'package:source_code/models/thread.dart';
import 'package:source_code/models/user.dart';
import 'package:source_code/models/word.dart';
import 'package:source_code/utils/preference.dart';

class FirebaseManager {
  late FirebaseFirestore db;
  late FirebaseAuth auth;

  FirebaseManager() {
    db = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
  }

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  String get uid => auth.currentUser?.uid ?? Preferences().uid;

  //region login/logout

  Future<void> userRegister(String email, String username, String password) async {
    QuerySnapshot querySnapshot =
        await db.collection(UserFields.collection).where(UserFields.email, isEqualTo: email).get();
    if (querySnapshot.docs.isNotEmpty) {
      throw (CustomException("Username already taken"));
    }

    try {
      String user_id = await createUser(email, password);
      AppUser appUser = AppUser(
          userId: user_id,
          username: username,
          email: email,
          level: 1,
          currentPoints: 0,
          levelPoints: 10,
          lastLevelUpdate: DateTime.now());

      DocumentReference doc = await db.collection(UserFields.collection).add(appUser.toJson());
      print('userRegister: user created $appUser');
    } catch (e) {
      print("userRegister: $e");
      throw (CustomException("Register failed: $e"));
    }
  }

  Future<String> createUser(String username, String password) async {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: username,
      password: password,
    );
    return userCredential.user!.uid;
  }

  Future<void> userLogin(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = FirebaseAuth.instance.currentUser;
      QuerySnapshot querySnapshot = await db
          .collection(UserFields.collection)
          .where(UserFields.email, isEqualTo: email)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        String username = querySnapshot.docs.first.get(UserFields.username);
        await Preferences().savePrefForLoggedIn(username, user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      print("userLogin: ${e.message}");
      throw (CustomException('Incorrect username or password'));
    } catch (e, stacktrace) {
      print("userLogin: $e");
      print("userLogin: $stacktrace");
      throw (CustomException(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await auth.signOut();
      // After signing out, you can navigate to the login page or any other page as needed.
      // For example, you can use Navigator to navigate to the login page:
      // Navigator.pushReplacementNamed(context, '/login');
    } catch (e, stacktrace) {
      print("logout: $e");
      print("logout: $stacktrace");
      throw (CustomException(e.toString()));
    }
  }

  //endregion

  //region user

  Future<AppUser?> getUserData(String userId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(UserFields.collection)
          .where(UserFields.user_id, isEqualTo: userId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> map = querySnapshot.docs.first.data() as Map<String, dynamic>;
        print("getUserData: map");
        return AppUser.fromJson(map);
      } else {
        throw Exception("Cannot find user profile for $userId");
      }
    } catch (e, stacktrace) {
      print("getUserData: $e");
      print("getUserData: $stacktrace");
      return null;
    }
  }

  Future<void> updateTargetReading(int? value) async {
    try {
      // Get the reference to the user document using the UID
      QuerySnapshot querySnapshot = await db
          .collection(UserFields.collection)
          .where(UserFields.user_id, isEqualTo: uid)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference userRef = querySnapshot.docs.first.reference;
        await userRef.set(
          {
            UserFields.target_reading: value,
          },
          // This will update the specified field and create it if it doesn't exist
          SetOptions(merge: true),
        );
      } else {
        throw Exception("Cannot find user profile");
      }
      // DocumentReference userRef = db.collection(UserFields.collection).doc(uid);
    } catch (e, stacktrace) {
      print("updateTargetReading: $e");
      print("updateTargetReading: $stacktrace");
      throw (CustomException(e.toString()));
    }
  }

  Future<void> updateTargetReadingTime(String? time) async {
    try {
      // Get the reference to the user document using the UID
      QuerySnapshot querySnapshot = await db
          .collection(UserFields.collection)
          .where(UserFields.user_id, isEqualTo: uid)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference userRef = querySnapshot.docs.first.reference;
        await userRef.set(
          {
            UserFields.target_time: time,
          },
          // This will update the specified field and create it if it doesn't exist
          SetOptions(merge: true),
        );
      } else {
        throw Exception("Cannot find user profile");
      }
      // DocumentReference userRef = db.collection(UserFields.collection).doc(uid);
    } catch (e, stacktrace) {
      print("updateTargetReadingTime: $e");
      print("updateTargetReadingTime: $stacktrace");
      throw (CustomException(e.toString()));
    }
  }

  Future<void> updateUserLevel(int currentPoints, {int? level, int? levelPoints}) async {
    try {
      // Get the reference to the user document using the UID
      QuerySnapshot querySnapshot = await db
          .collection(UserFields.collection)
          .where(UserFields.user_id, isEqualTo: uid)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference userRef = querySnapshot.docs.first.reference;
        var data = {
          UserFields.current_points: currentPoints,
          UserFields.last_level_update: DateTime.now().toString()
        };
        if (level != null) {
          data[UserFields.level] = level;
        }
        if (levelPoints != null) {
          data[UserFields.level_points] = levelPoints;
        }
        await userRef.update(data);
      } else {
        throw Exception("Cannot find user profile");
      }
      // DocumentReference userRef = db.collection(UserFields.collection).doc(uid);
    } catch (e, stacktrace) {
      print("updateUserLevel: $e");
      print("updateUserLevel: $stacktrace");
      throw (CustomException(e.toString()));
    }
  }

  //endregion

  // region thread
  Future<List<Thread>> getThreadList() async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(ThreadFields.collection)
          .orderBy(ThreadFields.post_time, descending: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Thread> threads = [];
        for (var element in querySnapshot.docs) {
          Map<String, dynamic> map = element.data() as Map<String, dynamic>;
          print("getThreadList: $map");
          Thread thread = Thread.fromJson(map);
          thread.commentNumber = await getCommentNumber(thread.threadId);
          thread.author = await getUserData(thread.userId);
          threads.add(thread);
        }
        return threads;
      } else {
        return [];
      }
    } catch (e, stacktrace) {
      print("getThreadList: $e");
      print("getThreadList: $stacktrace");
      return [];
    }
  }

  Future<int> getCommentNumber(String threadId) async {
    try {
      AggregateQuerySnapshot snapshot = await db
          .collection(CommentFields.collection)
          .where(CommentFields.thread_id, isEqualTo: threadId)
          .count()
          .get();
      return snapshot.count;
    } catch (e, stacktrace) {
      print("getCommentNumber: $e");
      print("getCommentNumber: $stacktrace");
      return 0;
    }
  }

  Future<List<Comment>> getComments(String threadId) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(CommentFields.collection)
          .where(ThreadFields.thread_id, isEqualTo: threadId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Comment> comments = [];
        for (var element in querySnapshot.docs) {
          Map<String, dynamic> map = element.data() as Map<String, dynamic>;
          print("getComments: $map");
          Comment comment = Comment.fromJson(map);
          comment.author = await getUserData(comment.userId);
          comments.add(comment);
        }
        return comments;
      } else {
        return [];
      }
    } catch (e, stacktrace) {
      print("getComments: $e");
      print("getComments: $stacktrace");
      return [];
    }
  }

  Future<void> createThread(Thread thread) async {
    try {
      DocumentReference doc = await db.collection(ThreadFields.collection).add(thread.toJson());
      print('createThread: success');
    } catch (e, stacktrace) {
      print("createThread: $e");
      print("createThread: $stacktrace");
      throw (CustomException("createThread failed: $e"));
    }
  }

  Future<void> addComment(Comment comment) async {
    try {
      DocumentReference doc = await db.collection(CommentFields.collection).add(comment.toJson());
      print('addComment: success');
    } catch (e, stacktrace) {
      print("addComment: $e");
      print("addComment: $stacktrace");
      throw (CustomException("addComment failed: $e"));
    }
  }

  Future<void> toggleLikeThread(Thread thread) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(ThreadFields.collection)
          .where(ThreadFields.thread_id, isEqualTo: thread.threadId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference threadRef = querySnapshot.docs.first.reference;
        await threadRef.update(
          {
            ThreadFields.liked_users: thread.likedUsers,
          },
        );
      } else {
        throw Exception("Cannot find thread");
      }
    } catch (e, stacktrace) {
      print("toggleLikeThread: $e");
      print("toggleLikeThread: $stacktrace");
    }
  }

  Future<void> toggleLikeComment(Comment comment) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(CommentFields.collection)
          .where(CommentFields.comment_id, isEqualTo: comment.commentId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference commentRef = querySnapshot.docs.first.reference;
        await commentRef.update(
          {
            CommentFields.liked_users: comment.likedUsers,
          },
        );
      } else {
        throw Exception("Cannot find comment");
      }
    } catch (e, stacktrace) {
      print("toggleLikeComment: $e");
      print("toggleLikeComment: $stacktrace");
    }
  }

//endregion

//region word
  //true = new word, false = word in history
  Future<bool> updateWordHistory(Word word) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(WordFields.collection)
          .where(WordFields.word, isEqualTo: word.word)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        DocumentReference doc = await db.collection(WordFields.collection).add(word.toJson());
        print('updateWordHistory: created word $word');
        return true;
      } else {
        DocumentReference wordRef = querySnapshot.docs.first.reference;
        await wordRef.update(
          {
            WordFields.search_time: word.searchTime.toString(),
          },
        );
        print('updateWordHistory: updated word $word');
        return false;
      }
    } catch (e, stacktrace) {
      print("updateWordHistory: $e");
      print("updateWordHistory: $stacktrace");
    }
    return false;
  }

  Future<List<Word>> getWordHistory() async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(WordFields.collection)
          .where(WordFields.user_id, isEqualTo: uid)
          .orderBy(WordFields.search_time, descending: true)
          .limit(100)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Word> words = [];
        for (var element in querySnapshot.docs) {
          Map<String, dynamic> map = element.data() as Map<String, dynamic>;
          print("getWordHistory: $map");
          Word word = Word.fromJson(map);
          words.add(word);
        }
        return words;
      } else {
        return [];
      }
    } catch (e, stacktrace) {
      print("getWordHistory: $e");
      print("getWordHistory: $stacktrace");
      return [];
    }
  }

//endregion

//region article
  //true = new article, false = article in history
  Future<bool> updateArticleHistory(Article article) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(ArticleFields.collection)
          .where(ArticleFields.url, isEqualTo: article.url)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        DocumentReference doc = await db.collection(ArticleFields.collection).add(article.toJson());
        print("updateArticleHistory: created article $article");
        return true;
      } else {
        DocumentReference articleRef = querySnapshot.docs.first.reference;
        await articleRef.update(
          {
            ArticleFields.search_time: article.searchTime.toString(),
          },
        );
        print("updateArticleHistory: updated article $article");
        return false;
      }
    } catch (e, stacktrace) {
      print("updateArticleHistory: $e");
      print("updateArticleHistory: $stacktrace");
    }
    return false;
  }

  Future<List<Article>> getArticleHistory() async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(ArticleFields.collection)
          .where(ArticleFields.user_id, isEqualTo: uid)
          .orderBy(ArticleFields.search_time, descending: true)
          .limit(10)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Article> articles = [];
        for (var element in querySnapshot.docs) {
          Map<String, dynamic> map = element.data() as Map<String, dynamic>;
          print("getArticleHistory: $map");
          Article article = Article.fromJson(map);
          articles.add(article);
        }
        return articles;
      } else {
        return [];
      }
    } catch (e, stacktrace) {
      print("getArticleHistory: $e");
      print("getArticleHistory: $stacktrace");
      return [];
    }
  }

//endregion

//region task
  Future<List<Task>> getCurrentTasks() async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(TaskFields.collection)
          .where(TaskFields.user_id, isEqualTo: uid)
          .where(TaskFields.finished, isEqualTo: false)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Task> tasks = [];
        for (var element in querySnapshot.docs) {
          Map<String, dynamic> map = element.data() as Map<String, dynamic>;
          print("getCurrentTasks: $map");
          Task task = Task.fromJson(map);
          tasks.add(task);
        }
        return tasks;
      } else {
        return [];
      }
    } catch (e, stacktrace) {
      print("getCurrentTasks: $e");
      print("getCurrentTasks: $stacktrace");
      return [];
    }
  }

  Future<List<Task>> getCompletedTasks() async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(TaskFields.collection)
          .where(TaskFields.user_id, isEqualTo: uid)
          .where(TaskFields.finished, isEqualTo: true)
          .orderBy(TaskFields.last_update_time, descending: true)
          .limit(3)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Task> tasks = [];
        for (var element in querySnapshot.docs) {
          Map<String, dynamic> map = element.data() as Map<String, dynamic>;
          print("getCompletedTasks: $map");
          Task task = Task.fromJson(map);
          tasks.add(task);
        }
        return tasks;
      } else {
        return [];
      }
    } catch (e, stacktrace) {
      print("getCompletedTasks: $e");
      print("getCompletedTasks: $stacktrace");
      return [];
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(TaskFields.collection)
          .where(TaskFields.task_id, isEqualTo: task.taskId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        DocumentReference doc = await db.collection(TaskFields.collection).add(task.toJson());
        print('updateTask: Task created $task');
      } else {
        DocumentReference taskRef = querySnapshot.docs.first.reference;
        await taskRef.update(
          {
            TaskFields.finished: task.finished,
            TaskFields.current: task.current,
            TaskFields.last_update_time: DateTime.now().toString(),
          },
        );
        print('updateTask: Task updated $task');
      }
    } catch (e, stacktrace) {
      print("updateTask: $e");
      print("updateTask: $stacktrace");
    }
  }

//endregion
}

class CustomException implements Exception {
  final String? message;

  CustomException(this.message);
}
