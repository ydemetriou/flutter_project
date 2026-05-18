import 'package:flutter/material.dart';

import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/expense_repository.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/loading_view.dart';
import 'expense_details_screen.dart';
import 'expense_form_screen.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  final _expenseRepository = ExpenseRepository();
  final _categoryRepository = CategoryRepository();

  List<Expense> _expenses = [];
  Map<int, String> _categoryNames = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final expenses = await _expenseRepository.getAllExpenses();
      final categories = await _categoryRepository.getAllCategories();
      if (!mounted) return;
      setState(() {
        _expenses = expenses;
        _categoryNames = _buildCategoryMap(categories);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<int, String> _buildCategoryMap(List<ExpenseCategory> categories) {
    return {
      for (final c in categories)
        if (c.id != null) c.id!: c.title,
    };
  }

  Future<void> _openAddExpense() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
    );
    if (result == true) {
      if (!mounted) return;
      SnackbarUtils.showMessage(context, 'Το έξοδο αποθηκεύτηκε');
      _loadData();
    }
  }

  Future<void> _openDetails(Expense expense) async {
    final categoryName =
        _categoryNames[expense.categoryId] ?? 'Άγνωστη κατηγορία';
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ExpenseDetailsScreen(expense: expense, categoryName: categoryName),
      ),
    );
    if (result == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Έξοδα')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpense,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView(message: 'Φόρτωση εξόδων...');
    }

    if (_errorMessage != null) {
      return const Center(child: Text('Κάτι πήγε στραβά. Δοκίμασε ξανά.'));
    }

    if (_expenses.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long,
        title: 'Δεν υπάρχουν έξοδα',
        message: 'Πάτησε + για να καταγράψεις το πρώτο σου έξοδο.',
      );
    }

    return ListView.builder(
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        final categoryName =
            _categoryNames[expense.categoryId] ?? 'Άγνωστη κατηγορία';
        return ExpenseCard(
          expense: expense,
          categoryName: categoryName,
          onTap: () => _openDetails(expense),
        );
      },
    );
  }
}
