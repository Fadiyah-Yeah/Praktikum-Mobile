import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  //singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin notificationPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await notificationPlugin.initialize(settings: initSettings);

    //request permission & create channel
    final androidPlatform = notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlatform?.requestNotificationsPermission();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel', // id
      'Reminder Notifications', // title
      description:
          'This channel is used for reminder notifications.', // description
      importance: Importance.high,
    );

    await androidPlatform?.createNotificationChannel(channel);
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const AndroidDetails = AndroidNotificationDetails(
      'reminder_channel', // id
      'Reminder Notifications', // title
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidDetails,
    );

    await notificationPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reminder_channel',
          'Reminder Notifications',
          importance: Importance.high,
          priority: Priority.high,
        );
    const NotificationDetails notifDetails = NotificationDetails(
      android: androidDetails,
    );
    await notificationPlugin.zonedSchedule(
      id: id,
      title:title,
      body:body,
      scheduledDate: tz.TZDateTime(
        tz.local,
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
        scheduledTime.hour,
        scheduledTime.minute,
      ),
      notificationDetails: notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
