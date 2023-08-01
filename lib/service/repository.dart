import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:source_code/models/thread.dart';
import 'package:source_code/models/user.dart';

class Repository {
  AppUser? user;
  List<Thread> allThreads = [];
  List<Thread> myThreads = [];

  void updateThread(List<Thread> threads) {
    allThreads.clear();
    myThreads.clear();
    allThreads.addAll(threads);
    myThreads.addAll(threads.where((element) => element.userId == user!.userId));
  }

  void reset() {
    user = null;
  }
}
