class DatabaseConstants {
  static const String databaseName = 'daily_expenses.db';
  static const int databaseVersion = 1;

  static const String categoriesTable = 'categories';
  static const String expensesTable = 'expenses';

  static const String categoryId = 'id';
  static const String categoryTitle = 'title';
  static const String categoryDescription = 'description';

  static const String expenseId = 'id';
  static const String expenseAmount = 'amount';
  static const String expenseDescription = 'description';
  static const String expenseCategoryId = 'category_id';
  static const String expenseDateTime = 'date_time';
  static const String expenseLatitude = 'latitude';
  static const String expenseLongitude = 'longitude';
  static const String expenseLocationName = 'location_name';
}
