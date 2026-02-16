import 'package:flutter/material.dart';
import '../models/savings_goal_model.dart'; // 确保路径正确
import 'cyber_card.dart'; // 确保路径正确

class VaultGoalCard extends StatelessWidget {
  final SavingsGoal goal;

  const VaultGoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vaultColor = const Color(0xFFFFBF00);

    // 计算进度
    double rawProgress = goal.targetAmount == 0 ? 0 : (goal.currentAmount / goal.targetAmount);
    double displayProgress = rawProgress.clamp(0.0, 1.0);
    bool isOverflown = rawProgress >= 1.0;
    Color activeColor = isOverflown ? Colors.greenAccent : vaultColor;

    return CyberCard(
      padding: const EdgeInsets.all(0),
      child: InkWell(
        onTap: () => _showDepositDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === 🔴 标题栏 + 操作按钮组 ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),

                  // 编辑按钮
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                    onPressed: () => _showEditGoalDialog(context),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    tooltip: "Edit Goal",
                  ),

                  const SizedBox(width: 15), // 按钮之间的间距

                  // 🔴 新增：删除按钮
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    onPressed: () => _showDeleteDialog(context),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    tooltip: "Delete Goal",
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // 金额显示
              Text(
                "¥ ${goal.currentAmount.toStringAsFixed(2)} / ${goal.targetAmount.toStringAsFixed(2)}",
                style: TextStyle(fontFamily: "Courier", color: activeColor, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              // 进度条
              LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 10,
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 10,
                          width: constraints.maxWidth * displayProgress,
                          decoration: BoxDecoration(
                              color: activeColor,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                if(isDark) BoxShadow(color: activeColor.withOpacity(0.6), blurRadius: 8)
                              ]
                          ),
                        ),
                      ],
                    );
                  }
              ),

              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${(rawProgress * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // === 弹窗逻辑 ===

  void _showDepositDialog(BuildContext context) {
    final amountCtrl = TextEditingController();
    bool isDeposit = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(isDeposit ? "CHARGE ENERGY" : "DISCHARGE", style: const TextStyle(fontFamily: "Courier", fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => isDeposit = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            color: isDeposit ? const Color(0xFFFFBF00) : Colors.transparent,
                            alignment: Alignment.center,
                            child: Text("DEPOSIT", style: TextStyle(color: isDeposit ? Colors.black : Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => isDeposit = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            color: !isDeposit ? Colors.redAccent : Colors.transparent,
                            alignment: Alignment.center,
                            child: Text("WITHDRAW", style: TextStyle(color: !isDeposit ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: TextStyle(color: isDeposit ? const Color(0xFFFFBF00) : Colors.redAccent, fontSize: 24, fontFamily: "Courier"),
                    decoration: InputDecoration(
                      labelText: isDeposit ? "Amount to Add" : "Amount to Remove",
                      prefixText: isDeposit ? "+ " : "- ",
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountCtrl.text);
                    if (amount != null) {
                      if (isDeposit) goal.currentAmount += amount;
                      else goal.currentAmount -= amount;
                      goal.save();
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isDeposit ? const Color(0xFFFFBF00) : Colors.redAccent,
                      foregroundColor: isDeposit ? Colors.black : Colors.white
                  ),
                  child: const Text("CONFIRM"),
                )
              ],
            );
          }
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: goal.name);
    final targetCtrl = TextEditingController(text: goal.targetAmount.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text("EDIT TARGET", style: TextStyle(fontFamily: "Courier", fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Goal Name")),
            TextField(controller: targetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Target Amount")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              goal.name = nameCtrl.text;
              goal.targetAmount = double.tryParse(targetCtrl.text) ?? goal.targetAmount;
              await goal.save();
              Navigator.pop(ctx);
            },
            child: const Text("UPDATE"),
          )
        ],
      ),
    );
  }

  // 🔴 删除弹窗逻辑
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // 跟随主题背景
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text("WARNING", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Destroy this savings target? \n此操作不可恢复，确定销毁该目标吗？"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              goal.delete(); // 从 Hive 数据库删除
              Navigator.pop(ctx); // 关闭弹窗
            },
            child: const Text("DESTROY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}