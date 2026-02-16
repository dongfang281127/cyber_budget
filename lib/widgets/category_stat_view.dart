import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import 'cyber_card.dart';

class CategoryStatView extends StatelessWidget {
  final List<Transaction> transactions;
  final bool showExpense;
  // 🔴 新增：传入时间范围标签，例如 "本周", "本月"
  final String scopeLabel;

  const CategoryStatView({
    super.key,
    required this.transactions,
    required this.showExpense,
    this.scopeLabel = "本月", // 默认值
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // 1. 过滤出 支出 or 收入
    final filtered = transactions.where((tx) => tx.isExpense == showExpense).toList();

    // 2. 按分类聚合
    Map<String, double> stats = {};
    double total = 0;
    for (var tx in filtered) {
      stats[tx.category] = (stats[tx.category] ?? 0) + tx.amount;
      total += tx.amount;
    }

    // 3. 排序
    var sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 🔴 4. 处理空数据情况 (使用动态的 scopeLabel)
    if (sortedEntries.isEmpty) {
      return CyberCard(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              Text(
                showExpense ? "NO EXPENSE" : "NO INCOME",
                style: TextStyle(fontFamily: "Courier", color: Colors.grey[600], letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              Text(
                "$scopeLabel无${showExpense ? '支出' : '收入'}记录", // 🔴 动态文字
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: sortedEntries.map((entry) {
        final catName = entry.key;
        final amount = entry.value;
        final percent = total == 0 ? 0.0 : amount / total;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CyberCard(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getIcon(catName), color: primaryColor, size: 20),
                ),
                const SizedBox(width: 15),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(catName, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: "Courier")),
                          Text("¥${amount.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: "Courier")),
                        ],
                      ),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey[800],
                        color: showExpense ? Colors.redAccent : Colors.greenAccent, // 🔴 颜色区分
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getIcon(String cat) {
    switch (cat) {
      case 'FOOD': return Icons.restaurant;
      case 'SNACKS': return Icons.fastfood; // 🔴 新增
      case 'TRAVEL': return Icons.train;
      case 'GAME': return Icons.sports_esports;
      case 'SHOPPING': return Icons.shopping_bag;
      case 'DIGITAL': return Icons.devices;
      case 'PARENTS': return Icons.family_restroom; // 🔴 新增
      default: return Icons.category;
    }
  }
}