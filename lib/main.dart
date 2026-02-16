import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'models/transaction_model.dart';
import 'models/savings_goal_model.dart';

// 🔴 1. 必须引入开场动画的文件
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(SavingsGoalAdapter());

  await Hive.openBox('settings');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<SavingsGoal>('vault_goals');

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
      title: 'Cyber Budget',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,

      // 🔴 2. 这里的 home 必须改成 SplashScreen()
      // 只有这样，App 启动才会先播动画，动画播完后再由 SplashScreen 跳转到 RootPage
      home: const SplashScreen(),
    );
  }
}