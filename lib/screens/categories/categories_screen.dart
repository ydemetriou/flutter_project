import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../repositories/category_repository.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/category_list_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_view.dart';
import 'category_form_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryRepository _categoryRepository = CategoryRepository();

  late Future<List<ExpenseCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    _categoriesFuture = _categoryRepository.getAllCategories();
  }

  void _refreshCategories() {
    setState(() {
      _loadCategories();
    });
  }

  Future<void> _openCategoryForm() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CategoryFormScreen()),
    );
    if (result == true) {
      if (!mounted) return;
      SnackbarUtils.showMessage(context, 'Η κατηγορία αποθηκεύτηκε');
      _refreshCategories();
    }
  }

  Future<void> _editCategory(ExpenseCategory category) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CategoryFormScreen(category: category)),
    );
    if (result == true) {
      if (!mounted) return;
      SnackbarUtils.showMessage(context, 'Η κατηγορία ενημερώθηκε');
      _refreshCategories();
    }
  }

  Future<void> _deleteCategory(ExpenseCategory category) async {
    if (category.id == null) return;

    final confirmed = await DialogUtils.showConfirmDelete(
      context,
      title: 'Διαγραφή κατηγορίας',
      content:
          'Θέλεις σίγουρα να διαγράψεις την κατηγορία "${category.title}";',
    );

    if (confirmed) {
      await _categoryRepository.deleteCategory(category.id!);
      if (!mounted) return;
      SnackbarUtils.showMessage(context, 'Η κατηγορία διαγράφηκε');
      _refreshCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Κατηγορίες εξόδων')),
      body: FutureBuilder<List<ExpenseCategory>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(message: 'Φόρτωση κατηγοριών...');
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Κάτι πήγε στραβά. Δοκίμασε ξανά.'),
            );
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return const EmptyState(
              icon: Icons.category,
              title: 'Δεν υπάρχουν κατηγορίες',
              message: 'Πάτησε + για να δημιουργήσεις την πρώτη κατηγορία.',
            );
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryListTile(
                category: category,
                onEdit: () => _editCategory(category),
                onDelete: () => _deleteCategory(category),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCategoryForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
