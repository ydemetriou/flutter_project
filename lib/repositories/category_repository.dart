import '../database/app_database.dart';
import '../database/database_constants.dart';
import '../models/expense_category.dart';

class CategoryRepository {
  Future<int> insertCategory(ExpenseCategory category) async {
    final db = await AppDatabase.database;
    return await db.insert(DatabaseConstants.categoriesTable, category.toMap());
  }

  Future<List<ExpenseCategory>> getAllCategories() async {
    final db = await AppDatabase.database;
    final result = await db.query(
      DatabaseConstants.categoriesTable,
      orderBy: '${DatabaseConstants.categoryTitle} ASC',
    );
    return result.map((map) => ExpenseCategory.fromMap(map)).toList();
  }

  Future<ExpenseCategory?> getCategoryById(int id) async {
    final db = await AppDatabase.database;
    final result = await db.query(
      DatabaseConstants.categoriesTable,
      where: '${DatabaseConstants.categoryId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return ExpenseCategory.fromMap(result.first);
  }

  Future<int> updateCategory(ExpenseCategory category) async {
    final db = await AppDatabase.database;
    return await db.update(
      DatabaseConstants.categoriesTable,
      category.toMap(),
      where: '${DatabaseConstants.categoryId} = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await AppDatabase.database;
    return await db.delete(
      DatabaseConstants.categoriesTable,
      where: '${DatabaseConstants.categoryId} = ?',
      whereArgs: [id],
    );
  }
}
