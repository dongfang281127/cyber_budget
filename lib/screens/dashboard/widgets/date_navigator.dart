import 'package:flutter/material.dart';

class DateNavigator extends StatelessWidget {
  final String dateStr;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback? onTitleTap; // 🔴 新增：点击标题的回调

  const DateNavigator({
    super.key,
    required this.dateStr,
    required this.onPrev,
    required this.onNext,
    this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          color: Colors.grey,
        ),

        // 🔴 中间区域改为可点击
        GestureDetector(
          onTap: onTitleTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.transparent, // 扩大点击区域
            child: Row(
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: "Courier",
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: theme.primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, color: theme.primaryColor.withOpacity(0.7)),
              ],
            ),
          ),
        ),

        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          color: Colors.grey,
        ),
      ],
    );
  }
}