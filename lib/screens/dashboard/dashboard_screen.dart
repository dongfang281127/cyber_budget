import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../widgets/category_stat_view.dart';

// 引入组件
import 'widgets/dashboard_header.dart';
import 'widgets/asset_overview_card.dart';
import 'widgets/scope_selector.dart';
import 'widgets/date_navigator.dart';
import 'widgets/financial_trend_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _scope = 'MONTH'; // WEEK, MONTH, YEAR
  DateTime _focusedDate = DateTime.now();
  bool _showExpenseList = true;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: ValueListenableBuilder<Box<Transaction>>(
        valueListenable: Hive.box<Transaction>('transactions').listenable(),
        builder: (context, box, _) {
          final allTx = box.values.toList().cast<Transaction>();

          // --- 数据过滤逻辑 ---
          double scopeIncome = 0;
          double scopeExpense = 0;
          String dateDisplayStr = "";
          String scopeLabelText = "";

          bool isInRange(DateTime date) {
            if (_scope == 'YEAR') {
              dateDisplayStr = DateFormat('yyyy').format(_focusedDate);
              scopeLabelText = "本年";
              return date.year == _focusedDate.year;
            } else if (_scope == 'MONTH') {
              dateDisplayStr = DateFormat('yyyy / MM').format(_focusedDate);
              scopeLabelText = "本月";
              return date.year == _focusedDate.year && date.month == _focusedDate.month;
            } else {
              // WEEK
              DateTime monday = _focusedDate.subtract(Duration(days: _focusedDate.weekday - 1));
              monday = DateTime(monday.year, monday.month, monday.day);
              DateTime sunday = monday.add(const Duration(days: 6));
              dateDisplayStr = "${DateFormat('MM/dd').format(monday)} - ${DateFormat('MM/dd').format(sunday)}";
              scopeLabelText = "本周";

              DateTime d = DateTime(date.year, date.month, date.day);
              DateTime m = DateTime(monday.year, monday.month, monday.day);
              DateTime s = DateTime(sunday.year, sunday.month, sunday.day);
              return (d.isAtSameMomentAs(m) || d.isAfter(m)) && (d.isAtSameMomentAs(s) || d.isBefore(s));
            }
          }

          List<Transaction> filteredTx = [];
          for (var tx in allTx) {
            if (isInRange(tx.date)) {
              filteredTx.add(tx);
              if (tx.isExpense) scopeExpense += tx.amount;
              else scopeIncome += tx.amount;
            }
          }

          double totalAssets = 0;
          for(var tx in allTx) {
            totalAssets += (tx.isExpense ? -tx.amount : tx.amount);
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardHeader(),
                  const SizedBox(height: 25),

                  ScopeSelector(
                    selectedScope: _scope,
                    onScopeChanged: (val) {
                      setState(() {
                        _scope = val;
                        _focusedDate = DateTime.now();
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  // 🔴 传入点击回调
                  DateNavigator(
                    dateStr: dateDisplayStr,
                    onPrev: () => _moveDate(-1),
                    onNext: () => _moveDate(1),
                    onTitleTap: _pickDate, // 绑定选择器
                  ),

                  const SizedBox(height: 20),

                  AssetOverviewCard(
                    balance: totalAssets,
                    monthIncome: scopeIncome,
                    monthExpense: scopeExpense,
                  ),

                  const SizedBox(height: 30),

                  FinancialTrendChart(
                    transactions: allTx,
                    scope: _scope,
                    focusedDate: _focusedDate,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: primaryColor, width: 3))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$scopeLabelText概览", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              "In: +${scopeIncome.toStringAsFixed(0)}  Out: -${scopeExpense.toStringAsFixed(0)}",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "Courier", color: primaryColor),
                            )
                          ],
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withOpacity(0.2))
                        ),
                        child: Row(
                          children: [
                            _buildToggleBtn("EXPENSE", true),
                            _buildToggleBtn("INCOME", false),
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 15),

                  CategoryStatView(
                    transactions: filteredTx,
                    showExpense: _showExpenseList,
                    scopeLabel: scopeLabelText,
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool isExpense) {
    bool isSelected = _showExpenseList == isExpense;
    return GestureDetector(
      onTap: () => setState(() => _showExpenseList = isExpense),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isExpense ? Colors.redAccent : Colors.greenAccent)
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

  void _moveDate(int direction) {
    setState(() {
      if (_scope == 'WEEK') {
        _focusedDate = _focusedDate.add(Duration(days: 7 * direction));
      } else if (_scope == 'MONTH') {
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + direction, 1);
      } else if (_scope == 'YEAR') {
        _focusedDate = DateTime(_focusedDate.year + direction, 1, 1);
      }
    });
  }

  // 🔴 弹出日期选择器
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _focusedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      // 设置为暗色或亮色主题适配
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // 头部颜色
              onPrimary: Colors.white, // 头部文字颜色
              onSurface: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black, // 日期文字颜色
            ),
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _focusedDate) {
      setState(() {
        _focusedDate = picked;
      });
    }
  }
}