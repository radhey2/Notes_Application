import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  static init() async {
    await _notification.initialize(const InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    ));
    tz.initializeTimeZones();
  }

  static scheduledNotification(
      int id, String title, String body, DateTime userSelectedDateTime) async {
    var androidDetails = const AndroidNotificationDetails(
        "important_notification", "My channel",
        importance: Importance.max, priority: Priority.high);

    // Convert the user's selected DateTime to TZDateTime
    final scheduledTime = tz.TZDateTime.from(userSelectedDateTime, tz.local);

    var notificationDetails = NotificationDetails(android: androidDetails);
    await _notification.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  cancelAllNotification() {
    _notification.cancelAll();
  }
}
