import 'package:flutter/material.dart';
import '../../../widgets/cyber_card.dart'; // 注意根据你的实际路径调整引用

class AssetOverviewCard extends StatelessWidget {
  final double balance;
  final double monthIncome;
  final double monthExpense;

  const AssetOverviewCard({
    super.key,
    required this.balance,
    required this.monthIncome,
    required this.monthExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    TextStyle labelStyle = TextStyle(
      color: isDark ? Colors.grey : Colors.black54,
      fontSize: 12,
      fontFamily: "Courier",
      letterSpacing: 1.5,
    );

    TextStyle valueStyle = TextStyle(
      color: theme.primaryColor,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: "Courier",
    );

    // 计算进度条逻辑
    double progressValue = 0.0;
    if (monthIncome > 0) {
      progressValue = (monthExpense / monthIncome).clamp(0.0, 1.0);
    } else if (monthExpense > 0) {
      progressValue = 1.0;
    }
    // 警戒色：如果花费超过收入的 90%，显示红色
    Color progressColor = progressValue > 0.9 ? Colors.redAccent : theme.primaryColor;

    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TOTAL ASSETS // 总资产", style: labelStyle),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text("¥", style: TextStyle(color: theme.primaryColor, fontSize: 20)),
              const SizedBox(width: 5),
              Text(balance.toStringAsFixed(2), style: valueStyle),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Month Out: -${monthExpense.toStringAsFixed(0)}", style: labelStyle),
              Text("Month In: +${monthIncome.toStringAsFixed(0)}", style: labelStyle),
            ],
          ),
          const SizedBox(height: 8),

          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(progressColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              monthIncome > 0
                  ? "Used: ${(progressValue * 100).toStringAsFixed(1)}% of Income"
                  : "No Income Data",
              style: TextStyle(fontSize: 10, color: progressColor, fontFamily: "Courier"),
            ),
          )
        ],
      ),
    );
  }
}