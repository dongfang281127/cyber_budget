import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SYSTEM ONLINE", style: labelStyle),
            const SizedBox(height: 5),
            Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.primaryColor),
          ),
          child: Icon(Icons.person_outline, color: theme.primaryColor),
        )
      ],
    );
  }
}