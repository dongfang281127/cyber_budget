import 'package:hive/hive.dart';

part 'savings_goal_model.g.dart';

@HiveType(typeId: 1)
class SavingsGoal extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  double currentAmount;

  @HiveField(3)
  int colorIndex;

  SavingsGoal({
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.colorIndex = 0,
  });

  // 🔴 新增：转成 Map (方便存成 JSON)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'colorIndex': colorIndex,
    };
  }

  // 🔴 新增：从 Map 变回对象
  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      name: map['name'] ?? 'Target',
      targetAmount: map['targetAmount']?.toDouble() ?? 0.0,
      currentAmount: map['currentAmount']?.toDouble() ?? 0.0,
      colorIndex: map['colorIndex'] ?? 0,
    );
  }
}