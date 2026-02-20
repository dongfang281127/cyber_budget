import 'package:flutter/material.dart';

class VaultTotalCard extends StatelessWidget {
  final double totalSaved;

  const VaultTotalCard({super.key, required this.totalSaved});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vaultColor = const Color(0xFFFFBF00);

    return Center(
      child: Container(
        width: 200, height: 200,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: vaultColor.withOpacity(0.2), width: 2),
            boxShadow: [
              if (isDark) BoxShadow(color: vaultColor.withOpacity(0.1), blurRadius: 30, spreadRadius: 10)
            ]
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 内圈装饰
            SizedBox(
              width: 180, height: 180,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 10,
                valueColor: AlwaysStoppedAnimation(vaultColor.withOpacity(0.1)),
              ),
            ),
            // 数字
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("TOTAL RESERVE", style: TextStyle(fontSize: 10, fontFamily: "Courier", color: vaultColor)),
                const SizedBox(height: 5),
// 🔴 核心修复：外层加一个 Padding 限制最大宽度，然后用 FittedBox 让文字自适应缩小
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20), // 左右留出安全边距，防止贴边
                  child: FittedBox(
                    fit: BoxFit.scaleDown, // 关键：只缩小，不换行，不放大
                    child: Text(
                      "¥ ${totalSaved.toStringAsFixed(2)}",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          fontFamily: "Courier"
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}