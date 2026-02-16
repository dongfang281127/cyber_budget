import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  // 默认是深色模式
  bool _isDarkMode = true;

  // 供外部获取当前状态
  bool get isDarkMode => _isDarkMode;

  // 获取当前的主题数据
  ThemeData get currentTheme => _isDarkMode ? AppThemes.cyberDark : AppThemes.geekLight;

  // 初始化：从本地数据库读取上次的设置
  ThemeProvider() {
    _loadFromHive();
  }

  // 切换开关
  void toggleTheme(bool isOn) {
    _isDarkMode = isOn;
    _saveToHive(isOn); // 保存到本地
    notifyListeners(); // 通知所有页面：颜色变了！
  }

  // --- 本地存储逻辑 ---

  // 从 Hive 读取
  void _loadFromHive() async {
    var box = await Hive.openBox('settings'); // 打开叫 settings 的盒子
    // get('darkMode', defaultValue: true) 意思就是：如果没存过，默认给 true
    _isDarkMode = box.get('darkMode', defaultValue: true);
    notifyListeners();
  }

  // 保存进 Hive
  void _saveToHive(bool value) async {
    var box = await Hive.openBox('settings');
    box.put('darkMode', value);
  }
}