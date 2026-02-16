import 'package:flutter/material.dart';

class ScopeSelector extends StatelessWidget {
  final String selectedScope; // 'WEEK', 'MONTH', 'YEAR'
  final Function(String) onScopeChanged;

  const ScopeSelector({
    super.key,
    required this.selectedScope,
    required this.onScopeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          _buildTab("1W", "WEEK", theme),
          _buildTab("1M", "MONTH", theme),
          _buildTab("1Y", "YEAR", theme),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value, ThemeData theme) {
    bool isSelected = selectedScope == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onScopeChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: "Courier",
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}