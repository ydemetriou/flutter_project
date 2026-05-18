import '../database/app_database.dart';
import '../database/database_constants.dart';
import '../models/expense.dart';
import '../models/expense_summary.dart';

class ExpenseRepository {
  Future<int> insertExpense(Expense expense) async {
    final db = await AppDatabase.database;
    return await db.insert(DatabaseConstants.expensesTable, expense.toMap());
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await AppDatabase.database;
    final result = await db.query(
      DatabaseConstants.expensesTable,
      orderBy: '${DatabaseConstants.expenseDateTime} DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  Future<List<Expense>> getExpensesByCategory(int categoryId) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      DatabaseConstants.expensesTable,
      where: '${DatabaseConstants.expenseCategoryId} = ?',
      whereArgs: [categoryId],
      orderBy: '${DatabaseConstants.expenseDateTime} DESC',
    );
    return result.map((map) => Expense.fromMap(map)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await AppDatabase.database;
    return await db.update(
      DatabaseConstants.expensesTable,
      expense.toMap(),
      where: '${DatabaseConstants.expenseId} = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await AppDatabase.database;
    return await db.delete(
      DatabaseConstants.expensesTable,
      where: '${DatabaseConstants.expenseId} = ?',
      whereArgs: [id],
    );
  }

  Future<List<ExpenseSummary>> getExpenseAnalysis({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      '''
      SELECT
        categories.title AS categoryTitle,
        SUM(expenses.amount) AS totalAmount
      FROM expenses
      INNER JOIN categories
        ON expenses.category_id = categories.id
      WHERE expenses.date_time BETWEEN ? AND ?
      GROUP BY categories.id
      ORDER BY totalAmount DESC
      ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return result.map((map) => ExpenseSummary.fromMap(map)).toList();
  }
}
