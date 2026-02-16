import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/transaction_model.dart';

class FinancialTrendChart extends StatelessWidget {
  final List<Transaction> transactions;
  final String scope; // WEEK, MONTH, YEAR
  final DateTime focusedDate;

  const FinancialTrendChart({
    super.key,
    required this.transactions,
    required this.scope,
    required this.focusedDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark; // 暂时没用到，注释掉避免警告

    // 1. 数据处理：生成三组数据点
    final data = _generateAllSpots();
    final incomeSpots = data['income']!;
    final expenseSpots = data['expense']!;
    final balanceSpots = data['balance']!;

    // 2. 计算 Y 轴最大值，保证三条线都能完整显示
    double maxY = 0;
    for (var list in [incomeSpots, expenseSpots, balanceSpots]) {
      for (var spot in list) {
        if (spot.y > maxY) maxY = spot.y;
      }
    }
    if (maxY == 0) maxY = 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("MARKET TREND // 资金走势", style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: "Courier")),
        const SizedBox(height: 10),

        // 图例 (Legend)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildLegend("IN", Colors.greenAccent),
            const SizedBox(width: 10),
            _buildLegend("OUT", Colors.redAccent),
            const SizedBox(width: 10),
            _buildLegend("NET", Colors.cyanAccent),
          ],
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4, // 简单的横向参考线
                getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => _getBottomTitles(value, meta),
                    interval: 1,
                    reservedSize: 22,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 1,
              maxX: _getMaxX(),
              minY: 0,
              maxY: maxY * 1.1,
              lineBarsData: [
                // 1. 收入线 (绿色)
                _buildLine(incomeSpots, Colors.greenAccent),
                // 2. 支出线 (红色)
                _buildLine(expenseSpots, Colors.redAccent),
                // 3. 结余线 (青色)
                _buildLine(balanceSpots, Colors.cyanAccent, isDashed: false, width: 2),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  // 🔴 修复点：新版本写法，使用 getTooltipColor 回调
                  getTooltipColor: (touchedSpot) => Colors.black87,

                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      Color color = spot.bar.color ?? Colors.white;
                      String label = "";
                      if (color == Colors.greenAccent) label = "In: ";
                      if (color == Colors.redAccent) label = "Out: ";
                      if (color == Colors.cyanAccent) label = "Net: ";

                      return LineTooltipItem(
                        "$label¥${spot.y.toStringAsFixed(0)}",
                        TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  LineChartBarData _buildLine(List<FlSpot> spots, Color color, {bool isDashed = false, double width = 3}) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: width,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      dashArray: isDashed ? [5, 5] : null,
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.1), color.withOpacity(0.0)],
        ),
      ),
    );
  }

  Map<String, List<FlSpot>> _generateAllSpots() {
    Map<int, double> incomeMap = {};
    Map<int, double> expenseMap = {};
    Map<int, double> balanceMap = {};

    int maxDays = _getMaxX().toInt();
    for (int i = 1; i <= maxDays; i++) {
      incomeMap[i] = 0.0;
      expenseMap[i] = 0.0;
      balanceMap[i] = 0.0;
    }

    for (var tx in transactions) {
      if (!_isInScope(tx)) continue;

      int key = _getDateKey(tx.date);
      if (tx.isExpense) {
        expenseMap[key] = (expenseMap[key] ?? 0) + tx.amount;
      } else {
        incomeMap[key] = (incomeMap[key] ?? 0) + tx.amount;
      }
    }

    for (int i = 1; i <= maxDays; i++) {
      balanceMap[i] = (incomeMap[i] ?? 0) - (expenseMap[i] ?? 0);
      if (balanceMap[i]! < 0) balanceMap[i] = 0;
    }

    return {
      'income': incomeMap.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList()..sort((a,b)=>a.x.compareTo(b.x)),
      'expense': expenseMap.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList()..sort((a,b)=>a.x.compareTo(b.x)),
      'balance': balanceMap.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList()..sort((a,b)=>a.x.compareTo(b.x)),
    };
  }

  int _getDateKey(DateTime date) {
    if (scope == 'YEAR') return date.month;
    if (scope == 'WEEK') return date.weekday;
    return date.day;
  }

  bool _isInScope(Transaction tx) {
    if (scope == 'YEAR') return tx.date.year == focusedDate.year;
    if (scope == 'MONTH') return tx.date.year == focusedDate.year && tx.date.month == focusedDate.month;
    if (scope == 'WEEK') {
      DateTime monday = focusedDate.subtract(Duration(days: focusedDate.weekday - 1));
      monday = DateTime(monday.year, monday.month, monday.day);
      DateTime sunday = monday.add(const Duration(days: 7));
      return tx.date.isAfter(monday.subtract(const Duration(seconds: 1))) && tx.date.isBefore(sunday);
    }
    return false;
  }

  double _getMaxX() {
    if (scope == 'WEEK') return 7;
    if (scope == 'YEAR') return 12;
    return DateUtils.getDaysInMonth(focusedDate.year, focusedDate.month).toDouble();
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    int index = value.toInt();
    TextStyle style = const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: "Courier");
    if (scope == 'WEEK') {
      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      if (index >= 1 && index <= 7) return Text(days[index - 1], style: style);
    } else if (scope == 'YEAR') {
      if (index % 3 == 0) return Text("${index}月", style: style);
    } else {
      if (index == 1 || index == 10 || index == 20 || index == 28) return Text("$index", style: style);
    }
    return const SizedBox.shrink();
  }
}