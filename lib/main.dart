import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'models/transaction_model.dart';
import 'models/savings_goal_model.dart';

// 🔴 1. 引入你的通知服务
import 'core/utils/notification_service.dart';

// 必须引入开场动画的文件
import 'screens/splash/splash_screen.dart';

void main() async {
  // 必须加这句，确保插件能绑定到原生系统
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive 数据库
  await Hive.initFlutter();

  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(SavingsGoalAdapter());

  await Hive.openBox('settings');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<SavingsGoal>('vault_goals');

  // 🔴 2. 关键修复：在这里初始化通知服务！(这是能收到通知的核心)
  await NotificationService.init((payload) {
    debugPrint("点击了通知，载荷: $payload");
  });

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const CyberApp(),
    ),
  );
}

class CyberApp extends StatelessWidget {
  const CyberApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'FinCore', // 🔴 这里决定了多任务后台卡片的名字
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,

      // 这里的 home 必须改成 SplashScreen()
      // 只有这样，App 启动才会先播动画，动画播完后再由 SplashScreen 跳转到 RootPage
      home: const SplashScreen(),
    );
  }
}