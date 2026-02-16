import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';
import 'dashboard/dashboard_screen.dart'; // 仪表盘
import 'logs/logs_screen.dart';           // 日志
import 'vault/vault_screen.dart';         // 金库
import 'system/system_screen.dart';       // 系统设置
import '../widgets/add_transaction_dialog.dart'; // 记账弹窗

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

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

        // 🔴 关键修改：缩小字体到 10，防止溢出
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