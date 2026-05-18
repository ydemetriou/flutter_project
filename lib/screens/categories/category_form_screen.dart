import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../repositories/category_repository.dart';

class CategoryFormScreen extends StatefulWidget {
  final ExpenseCategory? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final CategoryRepository _categoryRepository = CategoryRepository();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool _isSaving = false;

  bool get _isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.category?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSaving = true);

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    final category = ExpenseCategory(
      id: widget.category?.id,
      title: title,
      description: description.isEmpty ? null : description,
    );

    if (_isEditMode) {
      await _categoryRepository.updateCategory(category);
    } else {
      await _categoryRepository.insertCategory(category);
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ο τίτλος είναι υποχρεωτικός';
    }
    if (value.trim().length < 2) {
      return 'Ο τίτλος πρέπει να έχει τουλάχιστον 2 χαρακτήρες';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Επεξεργασία κατηγορίας' : 'Νέα κατηγορία'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Τίτλος κατηγορίας',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: _validateTitle,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Περιγραφή',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      minLines: 3,
      maxLines: 5,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveCategory,
        icon: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: Text(_isSaving ? 'Αποθήκευση...' : 'Αποθήκευση'),
      ),
    );
  }
}
