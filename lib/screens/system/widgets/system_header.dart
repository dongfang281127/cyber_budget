import 'package:flutter/material.dart';

class SystemHeader extends StatelessWidget {
  const SystemHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SYSTEM CONFIG",
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.black54,
                fontSize: 12,
                fontFamily: "Courier",
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Settings",
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
            border: Border.all(color: primaryColor),
          ),
          child: Icon(Icons.settings_outlined, color: primaryColor),
        )
      ],
    );
  }
}