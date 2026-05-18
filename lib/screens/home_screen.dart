import 'package:flutter/material.dart';

import '../widgets/app_menu_card.dart';
import 'analysis/expense_analysis_screen.dart';
import 'categories/categories_screen.dart';
import 'expenses/expenses_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Expenses')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppMenuCard(
            title: 'Κατηγορίες εξόδων',
            subtitle: 'Δημιουργία και προβολή κατηγοριών',
            icon: Icons.category,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
          ),
          const SizedBox(height: 12),
          AppMenuCard(
            title: 'Έξοδα',
            subtitle: 'Καταγραφή και προβολή εξόδων',
            icon: Icons.receipt_long,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExpensesListScreen()),
            ),
          ),
          const SizedBox(height: 12),
          AppMenuCard(
            title: 'Ανάλυση εξόδων',
            subtitle: 'Σύνολα ανά κατηγορία για επιλεγμένη περίοδο',
            icon: Icons.analytics,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExpenseAnalysisScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
