import 'package:flutter/material.dart';

class CyberColors {
  // === 黑夜模式 (Cyber Dark) ===
  static const Color darkBg = Color(0xFF050505);
  static const Color darkSurface = Color(0xFF121212);
  static const Color neonCyan = Color(0xFF00FFCC);  // 赛博青
  static const Color neonPink = Color(0xFFFF00CC);  // 蒸汽波粉
  static const Color matrixGreen = Color(0xFF00FF00); // 黑客绿

  // === 白天模式 (Geek Light) ===
  static const Color lightBg = Color(0xFFF0F2F5); // 极简灰白
  static const Color lightSurface = Colors.white;
  static const Color geekBlue = Color(0xFF0055FF); // 克莱因蓝 (国际主义风格)
  static const Color geekBlack = Color(0xFF222222); // 工程黑
  static const Color textMain = Colors.white;
  static const Color textDim = Colors.white54;
}

class AppThemes {
  // 1. 黑夜赛博主题
  static final ThemeData cyberDark = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: CyberColors.darkBg,
    primaryColor: CyberColors.neonCyan,
    colorScheme: const ColorScheme.dark(
      primary: CyberColors.neonCyan,
      secondary: CyberColors.neonPink,
      surface: CyberColors.darkSurface,
    ),
    // 底部导航栏样式
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: CyberColors.darkSurface,
      selectedItemColor: CyberColors.neonCyan,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    // 浮动按钮样式
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: CyberColors.neonPink,
      foregroundColor: Colors.white,
    ),
  );

  // 2. 白天极客主题 (工程图纸风)
  static final ThemeData geekLight = ThemeData.light().copyWith(
    scaffoldBackgroundColor: CyberColors.lightBg,
    primaryColor: CyberColors.geekBlue,
    colorScheme: const ColorScheme.light(
      primary: CyberColors.geekBlue,
      secondary: CyberColors.geekBlack,
      surface: CyberColors.lightSurface,
    ),
    // 底部导航栏样式
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: CyberColors.lightSurface,
      selectedItemColor: CyberColors.geekBlue,
      unselectedItemColor: Colors.grey,
      elevation: 10, // 白天模式阴影
      type: BottomNavigationBarType.fixed,
    ),
    // 浮动按钮样式
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: CyberColors.geekBlue,
      foregroundColor: Colors.white,
    ),
  );
}