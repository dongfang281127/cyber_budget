import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// 🔴 1. 必须写在类外面的顶级函数 (Top-level function)，用于处理后台/锁屏状态下的按钮点击
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  // 当用户点击通知栏里的按钮时，会触发这里
  if (notificationResponse.actionId == 'action_snooze') {
    // === 推迟逻辑 (Snooze) ===
    tz.initializeTimeZones();
    // 后台由于无法调用 MethodChannel，我们使用相对时间即可，强行给个默认时区不影响延时逻辑
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

    // 定一个 10 分钟后的新通知
    await plugin.zonedSchedule(
      999, // 推迟专用 ID
      'FinCore Reminder (Snoozed)',
      'Time to log your expenses! // 推迟的记账提醒到了',
      tz.TZDateTime.now(tz.local).add(const Duration(minutes: 10)), // 延迟 10 分钟
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminder',
          importance: Importance.max,
          priority: Priority.high,
          // 再次弹出的推迟通知，依然带上按钮
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction('action_snooze', '再推迟10分钟', cancelNotification: true),
            AndroidNotificationAction('action_dismiss', '结束', cancelNotification: true),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  } else if (notificationResponse.actionId == 'action_dismiss') {
    // === 结束逻辑 (Dismiss) ===
    // cancelNotification: true 已经把通知关了，后台其实不需要再做任何事
    debugPrint("Notification dismissed by user.");
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init(Function(String?)? onDidReceiveNotificationResponse) async {
    tz.initializeTimeZones();

    const MethodChannel platform = MethodChannel('com.fincore/timezone');
    String timeZoneName;
    try {
      timeZoneName = await platform.invokeMethod('getLocalTimezone');
    } catch (e) {
      timeZoneName = 'Asia/Shanghai';
    }

    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

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
      // 前台点击通知本体的回调
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == null && onDidReceiveNotificationResponse != null) {
          onDidReceiveNotificationResponse(response.payload);
        }
      },
      // 🔴 2. 绑定刚才写好的后台按钮点击回调
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  static Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // 测试通知 (立即发送)
  static Future<void> showInstantNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'instant_test_channel',
      'Test Notification',
      channelDescription: 'Testing if notifications work',
      importance: Importance.max,
      priority: Priority.high,
      // 🔴 3. 为测试通知也加上按钮
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('action_snooze', '推迟 10 分钟', cancelNotification: true),
        AndroidNotificationAction('action_dismiss', '结束', cancelNotification: true),
      ],
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      888,
      'FinCore Test',
      'If you see this, notifications are working! // 通知功能正常',
      details,
      payload: 'action_add',
    );
  }

  // 每日定时提醒
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
          // 🔴 4. 为定时通知加上按钮
          actions: <AndroidNotificationAction>[
            // cancelNotification: true 意味着只要点一下，原通知就会消失
            AndroidNotificationAction('action_snooze', '推迟 10 分钟', cancelNotification: true),
            AndroidNotificationAction('action_dismiss', '结束', cancelNotification: true),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}