import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/utils/notification_service.dart';

class NotificationSettingsCard extends StatefulWidget {
  const NotificationSettingsCard({super.key});

  @override
  State<NotificationSettingsCard> createState() => _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends State<NotificationSettingsCard> {
  bool _isReminderOn = false;
  bool _isLoading = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _isReminderOn = box.get('daily_reminder', defaultValue: false);
      int hour = box.get('reminder_hour', defaultValue: 20);
      int minute = box.get('reminder_minute', defaultValue: 0);
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
      _isLoading = false;
    });
  }

  void _toggleReminder(bool value) async {
    setState(() => _isReminderOn = value);
    final box = Hive.box('settings');
    await box.put('daily_reminder', value);

    if (value) {
      await NotificationService.requestPermissions();
      await NotificationService.scheduleDailyNotification(time: _reminderTime);
      final timeStr = _reminderTime.format(context);
      if (mounted) _showMsg("REMINDER SET // 已开启\nDaily at $timeStr");
    } else {
      await NotificationService.cancelAll();
      if (mounted) _showMsg("REMINDER OFF // 已关闭");
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(primary: theme.primaryColor, surface: Colors.grey[900]!)
                : ColorScheme.light(primary: theme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      setState(() => _reminderTime = picked);
      final box = Hive.box('settings');
      await box.put('reminder_hour', picked.hour);
      await box.put('reminder_minute', picked.minute);

      await NotificationService.scheduleDailyNotification(time: _reminderTime);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("TIME UPDATED // 时间已修改为 ${picked.format(context)}"),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    }
  }

  void _showMsg(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
          title: const Text("SYSTEM MESSAGE"),
          content: Text(msg),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("NOTIFICATIONS // 提醒", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text("Daily Reminder"),
                subtitle: Text("Notify daily at ${_reminderTime.format(context)}"),
                secondary: Icon(
                    _isReminderOn ? Icons.notifications_active : Icons.notifications_off,
                    color: _isReminderOn ? primaryColor : Colors.grey
                ),
                value: _isReminderOn,
                onChanged: _toggleReminder,
                activeColor: primaryColor,
              ),
              if (_isReminderOn) ...[
                const Divider(height: 1, indent: 70),
                ListTile(
                  leading: const SizedBox(width: 24),
                  title: const Text("Change Time // 修改时间", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: Icon(Icons.access_time, color: primaryColor, size: 20),
                  onTap: _pickTime,
                ),

                // 🔴 新增：临时的测试按钮，测完可以删掉
                const Divider(height: 1, indent: 70),
                ListTile(
                  leading: const SizedBox(width: 24),
                  title: const Text("Test Notification // 发送测试通知", style: TextStyle(fontSize: 12, color: Colors.amber)),
                  trailing: const Icon(Icons.send, color: Colors.amber, size: 20),
                  onTap: () async {
                    // 🔴 强制检查/请求一次权限
                    await NotificationService.requestPermissions();
                    // 🔴 发送测试通知
                    await NotificationService.showInstantNotification();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("已发送！快切到后台或下拉通知栏查看 👀")),
                      );
                    }
                  },
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}