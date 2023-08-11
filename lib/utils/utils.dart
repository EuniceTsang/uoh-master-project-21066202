import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/service/notification_manager.dart';
import 'package:source_code/service/task_manager.dart';
import 'package:source_code/utils/constants.dart';

class Utils {
  static String dateTimeToString(DateTime dateTime) {
    return dateTime.toString();
  }

  static String? dateTimeToStringNullable(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return dateTime.toString();
  }

  static DateTime? stringToDateTimeNullable(String? dateTimeString) {
    if (dateTimeString == null) {
      return null;
    }
    return DateTime.parse(dateTimeString);
  }

  static String formatTimeDifference(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);
    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  static Future loginInitialTasks(BuildContext context) async {
    TaskManager taskManager = context.read<TaskManager>();
    NotificationManager notificationManager = context.read<NotificationManager>();
    await taskManager.loadTask();
    if (taskManager.user != null) {
      notificationManager.scheduleNotification();
    }
    Navigator.pushReplacementNamed(context, Constants.routeBaseNavigation);
  }
}
