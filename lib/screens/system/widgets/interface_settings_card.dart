import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';

class InterfaceSettingsCard extends StatelessWidget {
  const InterfaceSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("INTERFACE // 界面", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Card(
          child: SwitchListTile(
            title: const Text("Cyber Mode"),
            subtitle: Text(isDark ? "Night" : "Day Light"),
            value: isDark,
            onChanged: (val) => themeProvider.toggleTheme(val),
            activeColor: primaryColor,
          ),
        ),
      ],
    );
  }
}