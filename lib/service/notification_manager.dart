import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:source_code/utils/preference.dart';

class NotificationManager {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('flutter_logo');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {});
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName', importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  Future showNotification({int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(id, title, body, await notificationDetails());
  }

  Future cancelScheduleNotification() async {
    notificationsPlugin.cancelAll();
  }

  Future scheduleNotification() async {
    await cancelScheduleNotification();
    String timeString = Preferences().targetTime;
    print("scheduleNotification: $timeString");
    if (timeString.isEmpty) {
      return;
    }
    List<String> parts = timeString.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    final now = DateTime.now();
    final notificationTime = DateTime(now.year, now.month, now.day, hour, minute);
    await notificationsPlugin.schedule(
        0,
        "Time to study today!",
        "Don't forget to take some time for studying and learning today. Learning consistently helps you achieve your goals. Happy studying!",
        notificationTime,
        await notificationDetails());
  }
}
