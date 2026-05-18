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

  List<ExpenseCategory>? _categories;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getAllCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  void _refreshCategories() {
    setState(() => _categories = null);
    _loadCategories();
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

  void _deleteCategory(ExpenseCategory category) {
    if (category.id == null) return;

    DialogUtils.showConfirmDelete(
      context,
      message: 'Θέλεις σίγουρα να διαγράψεις την κατηγορία "${category.title}";',
      onConfirm: () async {
        await _categoryRepository.deleteCategory(category.id!);
        if (!mounted) return;
        SnackbarUtils.showMessage(context, 'Η κατηγορία διαγράφηκε');
        _refreshCategories();
      },
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return const Center(child: Text('Κάτι πήγε στραβά. Δοκίμασε ξανά.'));
    }
    if (_categories == null) {
      return const LoadingView(message: 'Φόρτωση κατηγοριών...');
    }
    if (_categories!.isEmpty) {
      return const EmptyState(
        icon: Icons.category,
        title: 'Δεν υπάρχουν κατηγορίες',
        message: 'Πάτησε + για να δημιουργήσεις την πρώτη κατηγορία.',
      );
    }
    return ListView.builder(
      itemCount: _categories!.length,
      itemBuilder: (context, index) {
        final category = _categories![index];
        return CategoryListTile(
          category: category,
          onEdit: () => _editCategory(category),
          onDelete: () => _deleteCategory(category),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Κατηγορίες εξόδων')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCategoryForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}
