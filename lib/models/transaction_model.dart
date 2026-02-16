import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late bool isExpense;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late String category;

  Transaction({
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
    this.category = 'FOOD',
  });

  // 🔴 变身：转成 Map (方便存成 JSON)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'isExpense': isExpense,
      'date': date.toIso8601String(), // 把时间变成字符串
      'category': category,
    };
  }

  // 🔴 变回：从 Map 变回 Transaction 对象
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      title: map['title'] ?? 'Unknown',
      amount: map['amount']?.toDouble() ?? 0.0,
      isExpense: map['isExpense'] ?? true,
      date: DateTime.parse(map['date']),
      category: map['category'] ?? 'OTHER',
    );
  }
}