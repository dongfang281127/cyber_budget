import 'package:flutter/material.dart';
import '../../../core/utils/backup_service.dart';

class DataManagementSection extends StatelessWidget {
  const DataManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
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