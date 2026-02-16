import 'package:flutter/material.dart';

class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const CyberCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor, // 自动适配黑/白底色
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // 黑夜模式：青色发光边框；白天模式：黑色工程边框
            color: isDark ? primaryColor.withOpacity(0.5) : Colors.black,
            width: isDark ? 1 : 2,
          ),
          boxShadow: [
            isDark
            // === 黑夜模式：霓虹光晕 ===
                ? BoxShadow(
              color: primaryColor.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 2,
            )
            // === 白天模式：硬阴影 (工程图纸感) ===
                : const BoxShadow(
              color: Colors.black, // 纯黑硬阴影
              offset: Offset(4, 4), // 向右下偏移
              blurRadius: 0, // 不模糊
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}