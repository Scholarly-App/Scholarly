import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _plugin.initialize(initializationSettings);
  }

  static Future<void> showWelcomeNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'welcome_channel_id',
      'Welcome Notifications',
      channelDescription: 'This channel is for welcome notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      'Welcome Back Scholar!',
      'Glad to see you again 💪',
      notificationDetails,
    );

  }
}
