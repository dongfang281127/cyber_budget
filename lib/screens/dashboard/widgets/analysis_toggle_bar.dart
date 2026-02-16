import 'package:flutter/material.dart';

class AnalysisToggleBar extends StatelessWidget {
  final bool showExpense;
  final Function(bool) onToggle; // 回调函数

  const AnalysisToggleBar({
    super.key,
    required this.showExpense,
    required this.onToggle,
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("MONTHLY ANALYSIS", style: labelStyle),

        // 切换按钮组
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Row(
            children: [
              _buildTabButton("EXPENSE", true, theme),
              _buildTabButton("INCOME", false, theme),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTabButton(String text, bool isExpenseBtn, ThemeData theme) {
    bool isSelected = showExpense == isExpenseBtn;

    return GestureDetector(
      onTap: () => onToggle(isExpenseBtn), // 触发回调
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isExpenseBtn ? theme.primaryColor : Colors.greenAccent)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            fontFamily: "Courier",
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}