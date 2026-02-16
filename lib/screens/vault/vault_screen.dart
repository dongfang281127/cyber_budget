import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/savings_goal_model.dart';
// 引入拆分后的组件
import '../../widgets/vault_total_card.dart';
import '../../widgets/vault_goal_card.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 金库专属色：琥珀金
    final vaultColor = const Color(0xFFFFBF00);

    // 1. 定义统一的文字样式 (复用 Dashboard 的风格)
    TextStyle labelStyle() => TextStyle(
      color: isDark ? Colors.grey : Colors.black54,
      fontSize: 12,
      fontFamily: "Courier",
      letterSpacing: 1.5,
    );

    return Scaffold(
      body: ValueListenableBuilder<Box<SavingsGoal>>(
        valueListenable: Hive.box<SavingsGoal>('vault_goals').listenable(),
        builder: (context, box, _) {
          final goals = box.values.toList();

          double totalSaved = 0;
          for (var g in goals) totalSaved += g.currentAmount;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 🔴 顶部标题栏 (已统一风格) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SECURE VAULT", style: labelStyle()), // 统一的小标题样式
                          const SizedBox(height: 5),
                          Text(
                              "Savings Core", // 统一的大标题样式
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              )
                          ),
                        ],
                      ),
                      // 统一的圆形图标容器
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: vaultColor), // 保持琥珀色边框
                        ),
                        child: Icon(Icons.lock_outline, color: vaultColor), // 保持琥珀色图标
                      )
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 组件 1：总览大圆环
                  VaultTotalCard(totalSaved: totalSaved),

                  const SizedBox(height: 40),

                  // --- 目标列表标题 ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 这里也用了 labelStyle 保持一致
                      Text("ACTIVE TARGETS // 目标", style: labelStyle()),
                      IconButton(
                        onPressed: () => _showAddGoalDialog(context),
                        icon: Icon(Icons.add_circle_outline, color: vaultColor),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  // --- 列表 ---
                  if (goals.isEmpty)
                    _buildEmptyState()
                  else
                  // 组件 2：目标卡片
                    ...goals.map((goal) => VaultGoalCard(goal: goal)).toList(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.savings_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text("NO GOALS DETECTED", style: TextStyle(fontFamily: "Courier", color: Colors.grey)),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text("NEW TARGET", style: TextStyle(fontFamily: "Courier", fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, autofocus: true, decoration: const InputDecoration(labelText: "Goal Name")),
            TextField(controller: targetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Target Amount")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && targetCtrl.text.isNotEmpty) {
                final newGoal = SavingsGoal(
                    name: nameCtrl.text,
                    targetAmount: double.parse(targetCtrl.text)
                );
                await Hive.box<SavingsGoal>('vault_goals').add(newGoal);
                Navigator.pop(ctx);
              }
            },
            child: const Text("CREATE"),
          )
        ],
      ),
    );
  }
}