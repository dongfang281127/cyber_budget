import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../widgets/add_transaction_dialog.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1. 定义统一的文字样式 (复用 Dashboard 的风格)
    TextStyle labelStyle() => TextStyle(
      color: isDark ? Colors.grey : Colors.black54,
      fontSize: 12,
      fontFamily: "Courier",
      letterSpacing: 1.5,
    );

    return Scaffold(
      // 2. 去掉 AppBar，改用 SafeArea + Column
      body: SafeArea(
        child: Column(
          children: [
            // === 顶部自定义标题栏 (Dashboard 风格) ===
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), // 左上右下间距
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("DATABASE ACCESS", style: labelStyle()), // 小标题
                      const SizedBox(height: 5),
                      Text(
                          "Data Logs", // 大标题
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          )
                      ),
                    ],
                  ),
                  // 右侧图标 (保持一致性，也可以换成 Icons.list)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.primaryColor),
                    ),
                    child: Icon(Icons.list_alt, color: theme.primaryColor),
                  )
                ],
              ),
            ),

            // === 下方列表区域 ===
            Expanded(
              child: ValueListenableBuilder<Box<Transaction>>(
                valueListenable: Hive.box<Transaction>('transactions').listenable(),
                builder: (context, box, _) {
                  final transactions = box.values.toList().cast<Transaction>();

                  if (transactions.isEmpty) {
                    return const Center(child: Text("NO_DATA // 暂无记录", style: TextStyle(fontFamily: "Courier")));
                  }

                  // 排序
                  transactions.sort((a, b) => b.date.compareTo(a.date));

                  // 分组
                  Map<String, List<Transaction>> groupedData = {};
                  for (var tx in transactions) {
                    String dateKey = DateFormat('yyyy-MM-dd').format(tx.date);
                    if (groupedData[dateKey] == null) groupedData[dateKey] = [];
                    groupedData[dateKey]!.add(tx);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: groupedData.keys.length,
                    itemBuilder: (context, index) {
                      String dateKey = groupedData.keys.elementAt(index);
                      List<Transaction> dayList = groupedData[dateKey]!;

                      double dayTotal = 0;
                      for(var t in dayList) { if(t.isExpense) dayTotal += t.amount; }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDateTitle(dateKey),
                                  style: TextStyle(
                                    fontFamily: "Courier",
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Day Total: -${dayTotal.toStringAsFixed(0)}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                )
                              ],
                            ),
                          ),
                          ...dayList.map((tx) => _buildTransactionCard(context, tx, isDark, theme)).toList(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTitle(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    DateTime now = DateTime.now();

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "TODAY // 今天";
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return "YESTERDAY // 昨天";
    } else {
      return DateFormat('MMMM dd, yyyy').format(date).toUpperCase();
    }
  }

  Widget _buildTransactionCard(BuildContext context, Transaction tx, bool isDark, ThemeData theme) {
    final color = tx.isExpense
        ? (isDark ? const Color(0xFFFF0055) : Colors.redAccent)
        : (isDark ? const Color(0xFF00FFCC) : Colors.green);

    return Dismissible(
      key: Key(tx.key.toString()),
      background: Container(
        color: Colors.red.withOpacity(0.8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_forever, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: theme.scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12)
                ),
                title: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text("WARNING // 警告", style: TextStyle(fontFamily: "Courier", fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text("DELETE_DATA? \nThis action cannot be undone.\n\n确认要永久删除这条记录吗？"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text("DELETE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            }
        );
      },
      onDismissed: (_) => tx.delete(),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AddTransactionDialog(transaction: tx),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Row(
            children: [
              Icon(
                  tx.isExpense ? Icons.arrow_outward : Icons.arrow_downward,
                  color: color, size: 18
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87)),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text(
                        tx.category,
                        style: TextStyle(fontSize: 10, color: theme.primaryColor, fontFamily: "Courier"),
                      ),
                    )
                  ],
                ),
              ),
              Text(
                "${tx.isExpense ? '-' : '+'} ${tx.amount.toStringAsFixed(2)}",
                style: TextStyle(color: color, fontFamily: "Courier", fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}