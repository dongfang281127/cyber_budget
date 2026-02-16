import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart'; // 🔴 引入 MethodChannel
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init(Function(String?)? onDidReceiveNotificationResponse) async {
    // 1. 初始化时区数据
    tz.initializeTimeZones();

    // 🔴 2. 修改这里：使用 MethodChannel 获取原生时区
    const MethodChannel platform = MethodChannel('com.fincore/timezone');
    String timeZoneName;
    try {
      // 调用我们在 MainActivity.kt 里写的那个方法
      timeZoneName = await platform.invokeMethod('getLocalTimezone');
    } catch (e) {
      // 如果失败，兜底用上海时间 (防止崩溃)
      timeZoneName = 'Asia/Shanghai';
    }

    // 设置时区
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // 3. 安卓设置
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // 4. iOS 设置
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (onDidReceiveNotificationResponse != null) {
          onDidReceiveNotificationResponse(response.payload);
        }
      },
    );
  }

  static Future<void> requestPermissions() async {
    // Android 13+ 通知权限
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 🔴 Android 12+ 精确闹钟权限 (有些手机需要手动点)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // 🔴 新增：立即发送一条通知 (用来测试权限是否正常)
  static Future<void> showInstantNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'instant_test_channel',
      'Test Notification',
      channelDescription: 'Testing if notifications work',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      888, // 测试 ID
      'FinCore Test',
      'If you see this, notifications are working! // 通知功能正常',
      details,
      payload: 'action_add',
    );
  }

  static Future<void> scheduleDailyNotification({required TimeOfDay time}) async {
    await _notificationsPlugin.zonedSchedule(
      0,
      'FinCore Reminder',
      'Time to log your expenses! // 该记账啦',
      _nextInstanceOfTime(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminder',
          channelDescription: 'Reminds you to log expenses daily',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 允许在低电量模式下提醒
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'action_add',
    );
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);

    // 如果设置的时间比现在还早（比如现在 22:00，你设了 21:00），那就定在明天
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}