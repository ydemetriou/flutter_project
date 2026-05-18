import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_constants.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    if (Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _createDatabase,
    );
  }

  static Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.categoriesTable} (
        ${DatabaseConstants.categoryId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.categoryTitle} TEXT NOT NULL,
        ${DatabaseConstants.categoryDescription} TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DatabaseConstants.expensesTable} (
        ${DatabaseConstants.expenseId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.expenseAmount} REAL NOT NULL,
        ${DatabaseConstants.expenseDescription} TEXT,
        ${DatabaseConstants.expenseCategoryId} INTEGER NOT NULL,
        ${DatabaseConstants.expenseDateTime} TEXT NOT NULL,
        ${DatabaseConstants.expenseLatitude} REAL,
        ${DatabaseConstants.expenseLongitude} REAL,
        ${DatabaseConstants.expenseLocationName} TEXT,
        FOREIGN KEY (${DatabaseConstants.expenseCategoryId})
          REFERENCES ${DatabaseConstants.categoriesTable}(${DatabaseConstants.categoryId})
      )
    ''');
  }
}
