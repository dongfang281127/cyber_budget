import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/backup_service.dart';
import '../../core/utils/notification_service.dart';

class SystemScreen extends StatefulWidget {
  const SystemScreen({super.key});

  @override
  State<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> {
  bool _isReminderOn = false;
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _isReminderOn = box.get('daily_reminder', defaultValue: false);
      _isLoadingSettings = false;
    });
  }

  void _toggleReminder(bool value) async {
    setState(() {
      _isReminderOn = value;
    });

    final box = Hive.box('settings');
    await box.put('daily_reminder', value);

    if (value) {
      // 开启：请求权限 + 设置定时 (每晚 20:00)
      await NotificationService.requestPermissions();
      await NotificationService.scheduleDailyNotification(
        time: const TimeOfDay(hour: 20, minute: 0),
      );
      if (mounted) _showMsg(context, "REMINDER SET // 已开启\nDaily at 20:00");
    } else {
      // 关闭：取消所有通知
      await NotificationService.cancelAll();
      if (mounted) _showMsg(context, "REMINDER OFF // 已关闭");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;

    TextStyle labelStyle() => TextStyle(
      color: isDark ? Colors.grey : Colors.black54,
      fontSize: 12,
      fontFamily: "Courier",
      letterSpacing: 1.5,
    );

    return Scaffold(
      body: SafeArea(
        child: _isLoadingSettings
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // === 顶部标题 ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("SYSTEM CONFIG", style: labelStyle()),
                    const SizedBox(height: 5),
                    Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        )
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor),
                  ),
                  child: Icon(Icons.settings_outlined, color: primaryColor),
                )
              ],
            ),

            const SizedBox(height: 30),

            // === 界面设置 ===
            Text("INTERFACE // 界面", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Card(
              child: SwitchListTile(
                title: const Text("Cyber Mode"),
                subtitle: Text(isDark ? "Night" : "Day Light"),
                value: isDark,
                onChanged: (val) => themeProvider.toggleTheme(val),
                activeColor: primaryColor,
              ),
            ),

            const SizedBox(height: 20),

            // === 提醒设置 (已清理测试按钮) ===
            Text("NOTIFICATIONS // 提醒", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Card(
              child: SwitchListTile(
                title: const Text("Daily Reminder"),
                subtitle: const Text("Notify daily at 20:00"),
                secondary: Icon(
                    _isReminderOn ? Icons.notifications_active : Icons.notifications_off,
                    color: _isReminderOn ? primaryColor : Colors.grey
                ),
                value: _isReminderOn,
                onChanged: _toggleReminder,
                activeColor: primaryColor,
              ),
            ),

            const SizedBox(height: 20),

            // === 数据管理 ===
            Text("DATA_MANAGEMENT // 数据管理", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _buildActionCard(
              context,
              icon: Icons.upload_file,
              title: "BACKUP DATA // 导出备份",
              subtitle: "Save data to local storage",
              color: Colors.blueAccent,
              onTap: () async {
                _showLoading(context);
                String? path = await BackupService.exportData();
                Navigator.pop(context);

                if (path == "PERMISSION_DENIED") {
                  _showMsg(context, "Permission Denied!");
                } else if (path != null && path.startsWith("ERROR")) {
                  _showMsg(context, "Backup Failed:\n$path");
                } else if (path != null) {
                  _showMsg(context, "Backup Saved:\n$path");
                }
              },
            ),

            const SizedBox(height: 15),

            _buildActionCard(
              context,
              icon: Icons.download_rounded,
              title: "RESTORE DATA // 导入恢复",
              subtitle: "Overwrite current data",
              color: Colors.orangeAccent,
              onTap: () async {
                bool confirm = await _showConfirmDialog(context);
                if (!confirm) return;

                _showLoading(context);
                String? result = await BackupService.importData();
                Navigator.pop(context);

                if (result == "SUCCESS") {
                  _showMsg(context, "Data Restored Successfully!");
                } else if (result != null) {
                  _showMsg(context, "Restore Failed:\n$result");
                }
              },
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: "Courier")),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showMsg(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
          title: const Text("SYSTEM MESSAGE"),
          content: Text(msg),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]
      ),
    );
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("WARNING"),
        content: const Text("Restoring will OVERWRITE all current data.\n恢复将覆盖当前所有数据，确定吗？"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("CANCEL")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("CONFIRM", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    ) ?? false;
  }
}