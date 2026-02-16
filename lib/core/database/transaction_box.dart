import 'package:hive_flutter/hive_flutter.dart';
import '../../models/transaction_model.dart';

class TransactionBox {
  static const String boxName = 'transactions';

  // 打开盒子
  static Future<Box<Transaction>> openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<Transaction>(boxName);
    } else {
      return await Hive.openBox<Transaction>(boxName);
    }
  }

  // 1. 增加一笔账
  static Future<void> addTransaction(Transaction tx) async {
    final box = await openBox();
    await box.add(tx);
  }

  // 2. 获取所有账单 (按日期倒序)
  static List<Transaction> getAllTransactions() {
    final box = Hive.box<Transaction>(boxName);
    // 转换成 List 并排序
    List<Transaction> list = box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date)); // 新的在前
    return list;
  }

  // 3. 计算余额
  static double calculateBalance() {
    final box = Hive.box<Transaction>(boxName);
    double balance = 0;
    // 这里我们先假设初始资金是 0，以后可以做“设置初始资金”的功能
    // 或者我们定一个规则：只算收入 - 支出
    // 你也可以在这里加上“父母给的生活费总额”

    // 简单版算法：收入 - 支出
    for (var tx in box.values) {
      if (tx.isExpense) {
        balance -= tx.amount;
      } else {
        balance += tx.amount;
      }
    }
    return balance;
  }
}