import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🔴 1. 新增：引入系统服务协议，用于 MethodChannel
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'models/transaction_model.dart';
import 'models/savings_goal_model.dart';

// 引入你的通知服务
import 'core/utils/notification_service.dart';
// 必须引入开场动画的文件
import 'screens/splash/splash_screen.dart';

// 引入你的记账弹窗组件
import 'widgets/add_transaction_dialog.dart';

// 创建一个全局的导航钥匙，让我们可以在没有任何页面 Context 的地方弹出 Dialog
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 🔴 2. 新增：定义一个通道，名字必须和原生 Kotlin 里写的 QA_CHANNEL 完全一致！
const MethodChannel quickAddChannel = MethodChannel('com.fincore/quick_add');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(SavingsGoalAdapter());

  await Hive.openBox('settings');
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<SavingsGoal>('vault_goals');

  // 监听常驻通知的点击事件
  await NotificationService.init((payload) {
    debugPrint("点击了通知，载荷: $payload");

    // 如果点击的是我们的常驻快捷记账通知
    if (payload == 'action_quick_add') {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (navigatorKey.currentContext != null) {
          showDialog(
            context: navigatorKey.currentContext!,
            builder: (context) => const AddTransactionDialog(),
          );
        }
      });
    }
  });

  // 🔴 3. 新增：监听控制中心快捷开关的点击事件 (适用于 App 在后台“热启动”时)
  quickAddChannel.setMethodCallHandler((call) async {
    if (call.method == 'triggerQuickAdd') {
      // 稍微延迟 300 毫秒，等 App 从后台切到前台的动画过渡完，再弹出记账框体验更好
      Future.delayed(const Duration(milliseconds: 300), () {
        if (navigatorKey.currentContext != null) {
          showDialog(
            context: navigatorKey.currentContext!,
            builder: (context) => const AddTransactionDialog(),
          );
        }
      });
    }
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
      title: 'FinCore', // 这里决定了多任务后台卡片的名字
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: const SplashScreen(),
    );
  }
}