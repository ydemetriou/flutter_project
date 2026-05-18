import 'package:flutter/material.dart';

import '../models/expense_category.dart';

class CategoryListTile extends StatelessWidget {
  final ExpenseCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryListTile({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final description = category.description;

    return ListTile(
      leading: const Icon(Icons.category),
      title: Text(category.title),
      subtitle: description == null || description.trim().isEmpty
          ? const Text('Χωρίς περιγραφή')
          : Text(description),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            onEdit();
          } else if (value == 'delete') {
            onDelete();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Επεξεργασία')),
          PopupMenuItem(value: 'delete', child: Text('Διαγραφή')),
        ],
      ),
    );
  }
}
