import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import 'cyber_card.dart';

class AddTransactionDialog extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionDialog({super.key, this.transaction});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController(); // 你的模型用的是 title
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  String _selectedCategory = 'FOOD';

  final List<String> _categories = ['FOOD', 'SNACKS', 'TRAVEL', 'GAME', 'SHOPPING', 'DIGITAL', 'PARENTS', 'OTHER'];

  @override
  void initState() {
    super.initState();
    // 🔴 完美保留你的编辑回显逻辑
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _titleController.text = widget.transaction!.title; // 这里用的是 title
      _selectedDate = widget.transaction!.date;
      _isExpense = widget.transaction!.isExpense;
      _selectedCategory = widget.transaction!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    // 🔴 获取当前是否深色模式
    final isDark = theme.brightness == Brightness.dark;

    // 🔴 定义动态颜色 (白天黑字，晚上白字)
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;
    final Color borderColor = isDark ? Colors.white24 : Colors.black12;

    // 字体配置
    const double textSmall = 14.0;
    const double textNormal = 16.0;
    const double textLarge = 20.0;
    const double textHuge = 56.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: SingleChildScrollView(
        child: CyberCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 标题栏 ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.transaction == null ? "NEW_ENTRY // 新增记录" : "EDIT_LOG // 编辑记录",
                        style: TextStyle(
                          fontFamily: "Courier",
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: textLarge,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: subTextColor, size: 28),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  )
                ],
              ),

              const SizedBox(height: 20),

              // --- 金额输入 ---
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text("¥", style: TextStyle(fontSize: 30, color: primaryColor, fontFamily: "Courier")),
                    const SizedBox(width: 10),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        // 🔴 修复：金额颜色动态变化
                        style: TextStyle(
                          fontSize: textHuge,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontFamily: "Courier",
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                          // 🔴 修复：提示文字颜色
                          hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- 日期选择 ---
              InkWell(
                onTap: _presentDatePicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor), // 🔴 动态边框
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: primaryColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "DATE: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
                          // 🔴 修复：日期文字颜色
                          style: TextStyle(
                              fontFamily: "Courier",
                              fontSize: textNormal,
                              fontWeight: FontWeight.bold,
                              color: textColor
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("CHANGE", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- 备注输入 ---
              TextField(
                controller: _titleController, // 保持你的 title
                // 🔴 修复：输入文字颜色
                style: TextStyle(fontSize: textNormal, color: textColor),
                decoration: InputDecoration(
                  labelText: "Note / Remarks",
                  labelStyle: TextStyle(color: primaryColor, fontSize: textNormal),
                  prefixIcon: Icon(Icons.edit_note, color: primaryColor),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 2)),
                ),
              ),

              const SizedBox(height: 25),

              // --- 分类选择 ---
              Text("CATEGORY_TAGS:", style: TextStyle(fontFamily: "Courier", color: Colors.grey, fontSize: textSmall)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          // 🔴 动态边框
                          border: Border.all(color: isSelected ? primaryColor : borderColor),
                          boxShadow: isSelected
                              ? [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 8)]
                              : []
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              _getCategoryIcon(cat),
                              size: 16,
                              // 🔴 选中时根据黑白模式变色，未选中时灰色
                              color: isSelected ? (isDark ? Colors.black : Colors.white) : Colors.grey
                          ),
                          const SizedBox(width: 6),
                          Text(
                              cat,
                              style: TextStyle(
                                // 🔴 选中时文字变色
                                  color: isSelected ? (isDark ? Colors.black : Colors.white) : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Courier",
                                  fontSize: 14
                              )
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // --- 底部开关和确认按钮 ---
              Row(
                children: [
                  // 开关
                  Container(
                    decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[200], // 🔴 动态背景
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: borderColor)
                    ),
                    child: Row(
                      children: [
                        _buildSwitchBtn("EXPENSE", true, Colors.redAccent),
                        _buildSwitchBtn("INCOME", false, Colors.greenAccent),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 确认按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? Colors.black : Colors.white, // 🔴 按钮文字颜色
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "CONFIRM",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "Courier"),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchBtn(String text, bool isExpenseBtn, Color color) {
    final isSelected = _isExpense == isExpenseBtn;
    return GestureDetector(
      onTap: () => setState(() => _isExpense = isExpenseBtn),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 13
          ),
        ),
      ),
    );
  }

  void _submitData() async {
    final enteredAmount = double.tryParse(_amountController.text);
    final enteredTitle = _titleController.text;

    if (enteredAmount == null || enteredAmount <= 0 || enteredTitle.isEmpty) {
      return;
    }

    // 🔴 逻辑不变，依然使用 Transaction
    if (widget.transaction != null) {
      widget.transaction!.title = enteredTitle;
      widget.transaction!.amount = enteredAmount;
      widget.transaction!.date = _selectedDate;
      widget.transaction!.isExpense = _isExpense;
      widget.transaction!.category = _selectedCategory;
      await widget.transaction!.save();
    } else {
      // 创建新记录
      final newTx = Transaction(
        title: enteredTitle,
        amount: enteredAmount,
        date: _selectedDate,
        isExpense: _isExpense,
        category: _selectedCategory,
      );
      final box = Hive.box<Transaction>('transactions');
      await box.add(newTx);
    }

    if (mounted) Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
              primary: theme.primaryColor,
              onPrimary: Colors.black,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            )
                : ColorScheme.light( // 🔴 修复：白天模式日历颜色
              primary: theme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'FOOD': return Icons.restaurant;
      case 'SNACKS': return Icons.fastfood;
      case 'TRAVEL': return Icons.train;
      case 'GAME': return Icons.sports_esports;
      case 'SHOPPING': return Icons.shopping_bag;
      case 'DIGITAL': return Icons.devices;
      case 'PARENTS': return Icons.family_restroom;
      default: return Icons.category;
    }
  }
}