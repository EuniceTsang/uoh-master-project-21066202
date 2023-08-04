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
      print('User created with ID: ${doc.id}');
    } catch (e) {
      print("Register failed: $e");
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
      print(e.message);
      throw (CustomException('Incorrect username or password'));
    } catch (e) {
      print(e);
      throw (CustomException(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await auth.signOut();
      // After signing out, you can navigate to the login page or any other page as needed.
      // For example, you can use Navigator to navigate to the login page:
      // Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error logging out: $e');
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
        print(map);
        return AppUser.fromJson(map);
      } else {
        throw Exception("Cannot find user profile for $userId");
      }
    } catch (e) {
      print(e);
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
    } catch (e) {
      print(e);
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
    } catch (e) {
      print(e);
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
    } catch (e) {
      print(e);
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
          print(map);
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
      print(e);
      print(stacktrace);
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
      print(e);
      print(stacktrace);
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
          print(map);
          Comment comment = Comment.fromJson(map);
          comment.author = await getUserData(comment.userId);
          comments.add(comment);
        }
        return comments;
      } else {
        return [];
      }
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
      return [];
    }
  }

  Future<void> createThread(Thread thread) async {
    try {
      DocumentReference doc = await db.collection(ThreadFields.collection).add(thread.toJson());
      print('thread created with ID: ${doc.id}');
    } catch (e) {
      print("createThread failed: $e");
      throw (CustomException("createThread failed: $e"));
    }
  }

  Future<void> addComment(Comment comment) async {
    try {
      DocumentReference doc = await db.collection(CommentFields.collection).add(comment.toJson());
      print('comment created with ID: ${doc.id}');
    } catch (e) {
      print("addComment failed: $e");
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
    } catch (e) {
      print("toggleLikeThread failed: $e");
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
    } catch (e) {
      print("toggleLikeComment failed: $e");
    }
  }

//endregion

//region word
  Future<void> updateWordHistory(Word word) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(WordFields.collection)
          .where(WordFields.word, isEqualTo: word.word)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        DocumentReference doc = await db.collection(WordFields.collection).add(word.toJson());
        print('word created with ID: ${doc.id}');
      } else {
        DocumentReference wordRef = querySnapshot.docs.first.reference;
        await wordRef.update(
          {
            WordFields.search_time: word.searchTime.toString(),
          },
        );
        print('updated word');
      }
    } catch (e) {
      print("updateWord failed: $e");
    }
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
          print(map);
          Word word = Word.fromJson(map);
          words.add(word);
        }
        return words;
      } else {
        return [];
      }
    } catch (e) {
      print("getWords failed: $e");
      return [];
    }
  }

//endregion

//region article
  Future<void> updateArticleHistory(Article article) async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(ArticleFields.collection)
          .where(ArticleFields.url, isEqualTo: article.url)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        DocumentReference doc = await db.collection(ArticleFields.collection).add(article.toJson());
        print('article created with ID: ${doc.id}');
      } else {
        DocumentReference articleRef = querySnapshot.docs.first.reference;
        await articleRef.update(
          {
            ArticleFields.search_time: article.searchTime.toString(),
          },
        );
        print('updated article');
      }
    } catch (e) {
      print("updateArticle failed: $e");
    }
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
          print(map);
          Article article = Article.fromJson(map);
          articles.add(article);
        }
        return articles;
      } else {
        return [];
      }
    } catch (e) {
      print("getArticles failed: $e");
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
          print(map);
          Task task = Task.fromJson(map);
          tasks.add(task);
        }
        return tasks;
      } else {
        return [];
      }
    } catch (e) {
      print("getCurrentTask failed: $e");
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
          print(map);
          Task task = Task.fromJson(map);
          tasks.add(task);
        }
        return tasks;
      } else {
        return [];
      }
    } catch (e) {
      print("getCompletedTask failed: $e");
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
        print('task created with ID: ${doc.id}');
      } else {
        DocumentReference taskRef = querySnapshot.docs.first.reference;
        await taskRef.update(
          {
            TaskFields.finished: task.finished,
            TaskFields.current: task.current,
            TaskFields.last_update_time: task.lastUpdateTime.toString(),
          },
        );
        print('updated task');
      }
    } catch (e) {
      print("updateTask failed: $e");
    }
  }

//endregion
}

class CustomException implements Exception {
  final String? message;

  CustomException(this.message);
}
