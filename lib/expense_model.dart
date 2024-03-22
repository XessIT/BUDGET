import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class Expense {
  @HiveField(0)
  late String date;

  @HiveField(1)
  late String category;

  @HiveField(2)
  late String amount;

  Expense({
    required this.date,
    required this.category,
    required this.amount,
  });
}

@HiveType(typeId: 1)
class AnotherModel {
  // Define another model if needed
}

// This line will generate the necessary adapter for Expense
@HiveType(typeId: 2)
class BudgetInfo {
  @HiveField(0)
  late double totalSpendAmount;

  @HiveField(1)
  late double totalAmount;

  @HiveField(2)
  late double remainingAmount;

  BudgetInfo({
    required this.totalSpendAmount,
    required this.totalAmount,
    required this.remainingAmount,
  });
}
