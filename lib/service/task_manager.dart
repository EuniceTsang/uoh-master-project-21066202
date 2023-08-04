import 'dart:math';

import 'package:source_code/models/task.dart';
import 'package:source_code/models/user.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/utils/preference.dart';
import 'package:uuid/uuid.dart';

class TaskManager {
  FirebaseManager firebaseManager;
  AppUser? user;
  List<Task> currentTasks = [];
  List<Task> completedTasks = [];

  TaskManager(this.firebaseManager);

  Future<void> loadTask() async {
    try {
      user = await firebaseManager.getUserData(firebaseManager.uid);
      currentTasks = await firebaseManager.getCurrentTasks();
      completedTasks = await firebaseManager.getCompletedTasks();
      while (currentTasks.length < 3) {
        Task newTask = await generateNewTask();
        currentTasks.add(newTask);
      }
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
  }

  Future<Task> generateNewTask() async {
    List<TaskType> existingTypes = [];
    currentTasks.forEach((task) => existingTypes.add((task.type)));
    completedTasks.forEach((task) => existingTypes.add(task.type));
    List<TaskType> unusedTypes =
        TaskType.values.where((element) => !existingTypes.contains(element)).toList();
    int randomIndex = Random().nextInt(unusedTypes.length);
    TaskType taskType = unusedTypes[randomIndex];

    int minValue = 0, maxValue = 0;
    int userLevelPoints = user!.levelPoints;
    switch (taskType) {
      //1-5
      case TaskType.Reading:
      case TaskType.ReviseWordHistory:
      case TaskType.ReplyInForum:
      case TaskType.PostInForum:
        minValue = 1;
        maxValue = min((userLevelPoints / 5).floor(), 5);
        break;
      //2-5
      case TaskType.ConsistentReading:
        minValue = 2;
        maxValue = min((userLevelPoints / 5).floor(), 5);
        break;
      //1-10
      case TaskType.VocabularyCheckInReading:
      case TaskType.VocabularyCheck:
        minValue = 1;
        maxValue = min((userLevelPoints / 5).floor(), 10);
        break;
      //1
      case TaskType.WordOfTheDay:
        minValue = 1;
        maxValue = 1;
        break;
    }
    int target = minValue + Random().nextInt(maxValue - minValue + 1);
    int points = target * 5;

    Task task = Task(
        taskId: Uuid().v4(),
        userId: Preferences().uid,
        type: taskType,
        target: target,
        current: 0,
        points: points,
        finished: false,
        lastUpdateTime: DateTime.now());
    await firebaseManager.updateTask(task);
    return task;
  }
}
