import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionInfoCard extends StatelessWidget {
  const VersionInfoCard({super.key});

  // 你的 GitHub Release 链接
  final String releaseUrl = "https://github.com/dongfang281127/cyber_budget/releases/latest";

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SYSTEM_INFO // 关于系统", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        InkWell(
          onTap: () => _showVersionDialog(context, primaryColor, isDark),
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
                  decoration: BoxDecoration(
                      color: Colors.purpleAccent.withOpacity(0.2),
                      shape: BoxShape.circle
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.purpleAccent),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "VERSION INFO // 版本信息",
                          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Courier")
                      ),
                      Text(
                          "v1.0.2 (Tap for details & updates)", // 🔴 升级为 1.0.2
                          style: TextStyle(fontSize: 10, color: Colors.grey)
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 弹出版本详情对话框
  void _showVersionDialog(BuildContext context, Color primaryColor, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        title: Column(
          children: [
            Icon(Icons.terminal, color: primaryColor, size: 40),
            const SizedBox(height: 10),
            Text(
              "FinCore v1.0.2", // 🔴 升级为 1.0.2
              style: TextStyle(
                fontFamily: "Courier",
                fontWeight: FontWeight.bold,
                color: primaryColor,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "UPDATE LOG // 更新日志:",
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.black54, fontFamily: "Courier"),
            ),
            const SizedBox(height: 10),

            // 🔴 最新的硬核更新日志！
            _buildLogItem("Feature: 深度接入系统底层，支持0耗电全局极速唤醒"),
            _buildLogItem("Module: 新增 [控制中心] 专属快捷记账开关"),
            _buildLogItem("Module: 新增 [桌面长按] 专属图标快捷菜单"),
            _buildLogItem("Module: 新增 [常驻通知栏] 快捷记账沉浸式入口"),
            _buildLogItem("Fix: 优化底层图片资源寻址逻辑，提升系统兼容性"),

            const SizedBox(height: 15),
            Text(
              "Developed by Dongfang",
              style: TextStyle(fontSize: 10, color: primaryColor.withOpacity(0.6), fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("CLOSE", style: TextStyle(color: Colors.grey, fontFamily: "Courier"))
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              _launchURL(context);
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text("GET UPDATE", style: TextStyle(fontFamily: "Courier", fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("> ", style: TextStyle(color: Colors.grey, fontFamily: "Courier")),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  // 执行跳转浏览器
  Future<void> _launchURL(BuildContext context) async {
    final Uri url = Uri.parse(releaseUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("SYSTEM ERROR // 无法打开浏览器，请检查网络或设置")),
        );
      }
    }
  }
}