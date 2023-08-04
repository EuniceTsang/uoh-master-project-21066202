import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:source_code/models/task.dart';
import 'package:source_code/models/user.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/utils/preference.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

class TaskManager {
  FirebaseManager firebaseManager;
  AppUser? user;
  List<Task> currentTasks = [];
  List<Task> completedTasks = [];
  int wordCheckedInArticle = 0;

  TaskManager(this.firebaseManager);

  Future<void> loadTask() async {
    try {
      user = await firebaseManager.getUserData(firebaseManager.uid);
      currentTasks = await firebaseManager.getCurrentTasks();
      completedTasks = await firebaseManager.getCompletedTasks();
      if (currentTasks.length < 3) {
        while (currentTasks.length < 3) {
          Task newTask = await generateNewTask();
          currentTasks.add(newTask);
        }
      } else {
        await resetTaskProgress();
      }
    } catch (e, stacktrace) {
      print("loadTask: $e");
      print("loadTask: $stacktrace");
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
      //range: 1-5
      case TaskType.Reading:
      case TaskType.ReviseWordHistory:
      case TaskType.ReplyInForum:
      case TaskType.PostInForum:
        minValue = 1;
        maxValue = min((userLevelPoints / 5).floor(), 5);
        break;
      //range: 2-5
      case TaskType.ConsistentReading:
        minValue = 2;
        maxValue = min((userLevelPoints / 5).floor(), 5);
        break;
      //range: 1-10
      case TaskType.VocabularyCheckInReading:
      case TaskType.VocabularyCheck:
        minValue = 1;
        maxValue = min((userLevelPoints / 5).floor(), 10);
        break;
      //range: 1
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
        lastUpdateTime: null);
    await firebaseManager.updateTask(task);
    return task;
  }

  Future<void> resetWordCheckedInArticle() async {
    wordCheckedInArticle = 0;
  }

  Future<void> resetTaskProgress() async {
    bool changed = false;
    for (Task task in currentTasks) {
      DateTime? taskLastUpdate = task.lastUpdateTime;
      if (taskLastUpdate == null) {
        //new task
        continue;
      }
      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(Duration(days: 1));
      bool reset = false;
      switch (task.type) {
        case TaskType.Reading:
        case TaskType.VocabularyCheck:
          //must finish in one day
          if (!isSameDay(taskLastUpdate, now)) {
            task.current = 0;
            reset = true;
          }
          break;
        case TaskType.ConsistentReading:
          // set 0 if didn't read more than one day
          if (!isSameDay(taskLastUpdate, now) && !isSameDay(taskLastUpdate, yesterday)) {
            task.current = 0;
            reset = true;
          }
          break;
        case TaskType.VocabularyCheckInReading:
        case TaskType.WordOfTheDay:
        case TaskType.ReviseWordHistory:
        case TaskType.ReplyInForum:
        case TaskType.PostInForum:
          break;
      }
      if (reset) {
        changed = true;
        print("resetTaskProgress: reset task $task");
        await firebaseManager.updateTask(task);
      }
    }
    if (changed) {
      currentTasks = await firebaseManager.getCurrentTasks();
    }
    return;
  }

  Future<void> checkTasksAchieve(List<TaskType> taskTypes) async {
    print("checkTasksAchieve: $taskTypes");
    print("checkTasksAchieve: $currentTasks");
    for (TaskType taskType in taskTypes) {
      Task? task = currentTasks.firstWhereOrNull((item) => item.type == taskType);
      if (task == null) {
        continue;
      }
      if (task.type == TaskType.ConsistentReading) {
        DateTime now = DateTime.now();
        if (task.lastUpdateTime != null && isSameDay(now, task.lastUpdateTime!)) {
          //today already added points
          continue;
        }
      }
      if (task.type == TaskType.VocabularyCheckInReading) {
        wordCheckedInArticle++;
        print("wordCheckedInArticle: $wordCheckedInArticle");
        if (wordCheckedInArticle > task.current) {
          task.current = wordCheckedInArticle;
        }
      } else {
        task.current += 1;
      }
      if (task.current == task.target) {
        await taskCompleted(task);
      }
      print("checkTasksAchieve, updated: $task");
      await firebaseManager.updateTask(task);
    }
    await loadTask();
  }

  Future<void> taskCompleted(Task task) async {
    bool levelUp = false;
    task.finished = true;
    user!.currentPoints += task.points;
    if (user!.currentPoints >= user!.levelPoints) {
      //level up
      levelUp = true;
      user!.level += 1;
      user!.currentPoints -= user!.levelPoints;
      user!.levelPoints = user!.level * 10;
      showCustomEasyLoading(Icons.military_tech, "Level up", 3);
      print("taskCompleted: level up");
    } else {
      showCustomEasyLoading(Icons.task_alt, "Task completed", 3);
      print("taskCompleted: task completed");
    }
    await firebaseManager.updateUserLevel(user!.currentPoints,
        level: levelUp ? user!.level : null, levelPoints: levelUp ? user!.levelPoints : null);
  }

  bool isSameDay(DateTime dateTime1, DateTime dateTime2) {
    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day;
  }

  void showCustomEasyLoading(IconData icon, String text, int delayDismiss) {
    EasyLoading.show(
        maskType: EasyLoadingMaskType.black,
        indicator: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 80,
            ),
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 20),
            )
          ],
        ));
    Future.delayed(Duration(seconds: 3), () {
      EasyLoading.dismiss();
    });
  }
}
