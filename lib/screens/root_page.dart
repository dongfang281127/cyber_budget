import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// 引入快捷方式插件
import 'package:quick_actions/quick_actions.dart';

import '../core/theme/theme_provider.dart';
import 'dashboard/dashboard_screen.dart'; // 仪表盘
import 'logs/logs_screen.dart';           // 日志
import 'vault/vault_screen.dart';         // 金库
import 'system/system_screen.dart';       // 系统设置
import '../widgets/add_transaction_dialog.dart'; // 记账弹窗

// 定义控制中心快捷指令通道
const MethodChannel _quickAddChannel = MethodChannel('com.fincore/quick_add');

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkQuickAddFromColdStart(); // 检查下拉控制中心的指令
    _setupQuickActions();          // 🔴 初始化桌面长按快捷菜单
  }

  // 🔴 桌面长按菜单的核心逻辑
  void _setupQuickActions() {
    const QuickActions quickActions = QuickActions();

    // 监听点击事件
    quickActions.initialize((String shortcutType) {
      if (shortcutType == 'action_quick_add') {
        // 稍微延迟，等页面完全渲染出来再弹窗，体验更丝滑
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _onAddPressed();
          }
        });
      }
    });

    // 设置菜单项
    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_quick_add',
        localizedTitle: '快速记账',
        // 🔴 这里直接写图片名字（不带后缀），安卓系统会自动去 drawable 文件夹里找它！
        icon: 'ic_signature',
      ),
    ]);
  }

  // 检查控制中心冷启动
  Future<void> _checkQuickAddFromColdStart() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final bool shouldOpen = await _quickAddChannel.invokeMethod('checkQuickAdd');
      if (shouldOpen && mounted) {
        _onAddPressed();
      }
    } catch (e) {
      debugPrint("快捷开关冷启动检查失败: $e");
    }
  }

  // 页面列表
  final List<Widget> _pages = const [
    DashboardScreen(),
    LogsScreen(),
    SizedBox(), // 占位符，为了中间的 + 号
    VaultScreen(),
    SystemScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) return; // 点击中间占位符无效
    setState(() {
      _currentIndex = index;
    });
  }

  void _onAddPressed() async {
    await showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // 悬浮按钮位置
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 中间的 + 号按钮
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30),
        height: 64,
        width: 64,
        child: FloatingActionButton(
          onPressed: _onAddPressed,
          elevation: 10,
          shape: const CircleBorder(),
          // 赛博青色背景 (深色模式)
          backgroundColor: isDark
              ? const Color(0xFF00E5FF)
              : theme.primaryColor,
          child: Icon(
              Icons.add,
              size: 32,
              color: isDark ? Colors.black : Colors.white
          ),
        ),
      ),

      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed, // 确保文字一直显示
        backgroundColor: theme.scaffoldBackgroundColor,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey,

        // 缩小字体到 10，防止溢出
        selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontFamily: "Courier",
            fontWeight: FontWeight.bold
        ),
        unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontFamily: "Courier"
        ),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'DASHBOARD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'LOGS',
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(), // 空白占位
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined), // 金库图标
            label: 'VAULT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'SYSTEM',
          ),
        ],
      ),
    );
  }
}