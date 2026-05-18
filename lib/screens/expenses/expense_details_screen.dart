import 'package:flutter/material.dart';

import '../../models/expense.dart';
import '../../repositories/expense_repository.dart';
import '../../utils/app_date_utils.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/money_utils.dart';
import '../../utils/snackbar_utils.dart';
import 'expense_form_screen.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  final Expense expense;
  final String categoryName;

  const ExpenseDetailsScreen({
    super.key,
    required this.expense,
    required this.categoryName,
  });

  Future<void> _editExpense(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ExpenseFormScreen(expense: expense)),
    );
    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  void _deleteExpense(BuildContext context) {
    if (expense.id == null) return;

    DialogUtils.showConfirmDelete(
      context,
      message: 'Θέλεις σίγουρα να διαγράψεις αυτό το έξοδο;',
      onConfirm: () async {
        await ExpenseRepository().deleteExpense(expense.id!);
        if (context.mounted) {
          SnackbarUtils.showMessage(context, 'Το έξοδο διαγράφηκε');
          Navigator.pop(context, true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Λεπτομέρειες εξόδου'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Επεξεργασία',
            onPressed: () => _editExpense(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Διαγραφή',
            onPressed: () => _deleteExpense(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailCard(
            icon: Icons.euro,
            label: 'Ποσό',
            value: MoneyUtils.formatEuro(expense.amount),
            valueStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          _DetailCard(
            icon: Icons.category,
            label: 'Κατηγορία',
            value: categoryName,
          ),
          _DetailCard(
            icon: Icons.description,
            label: 'Περιγραφή',
            value: expense.description?.isNotEmpty == true
                ? expense.description!
                : 'Χωρίς περιγραφή',
          ),
          _DetailCard(
            icon: Icons.access_time,
            label: 'Ημερομηνία / Ώρα',
            value: AppDateUtils.formatDateTime(expense.dateTime),
          ),
          _DetailCard(
            icon: Icons.location_on,
            label: 'Τοποθεσία',
            value: expense.locationName ?? '-',
          ),
          _DetailCard(
            icon: Icons.map,
            label: 'Συντεταγμένες',
            value: expense.latitude != null && expense.longitude != null
                ? '${expense.latitude!.toStringAsFixed(4)}, '
                      '${expense.longitude!.toStringAsFixed(4)}'
                : '-',
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(value, style: valueStyle),
      ),
    );
  }
}
