import 'package:flutter/material.dart';

import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/expense_repository.dart';
import '../../services/location/location_service.dart';
import '../../utils/app_date_utils.dart';
import '../../utils/snackbar_utils.dart';
import '../categories/categories_screen.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;

  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _expenseRepository = ExpenseRepository();
  final _categoryRepository = CategoryRepository();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  List<ExpenseCategory>? _categories;
  int? _selectedCategoryId;

  double? _latitude;
  double? _longitude;
  String? _locationName;

  bool _isSaving = false;
  bool _isFetchingLocation = false;

  bool get _isEditMode => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense != null
          ? widget.expense!.amount.toStringAsFixed(2)
          : '',
    );
    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );
    _selectedCategoryId = widget.expense?.categoryId;
    _latitude = widget.expense?.latitude;
    _longitude = widget.expense?.longitude;
    _locationName = widget.expense?.locationName;
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepository.getAllCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      if (!_isEditMode &&
          categories.isNotEmpty &&
          _selectedCategoryId == null) {
        _selectedCategoryId = categories.first.id;
      }
    });
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _isFetchingLocation = true);

    try {
      final position = await LocationService.getCurrentPosition();

      String? locationName;
      try {
        locationName = await LocationService.getLocationName(
          position.latitude,
          position.longitude,
        );
      } catch (_) {
        // geocoding failed — coordinates still saved without name
      }

      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationName = locationName;
        _isFetchingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isFetchingLocation = false);
      SnackbarUtils.showMessage(context, 'Δεν ήταν δυνατή η λήψη τοποθεσίας.');
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Το ποσό είναι υποχρεωτικό';
    }
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) return 'Μη έγκυρος αριθμός';
    if (parsed <= 0) return 'Το ποσό πρέπει να είναι μεγαλύτερο από 0';
    return null;
  }

  Future<void> _saveExpense() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategoryId == null) return;

    setState(() => _isSaving = true);

    final amount = double.parse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    final description = _descriptionController.text.trim();

    final expense = Expense(
      id: widget.expense?.id,
      amount: amount,
      description: description.isEmpty ? null : description,
      categoryId: _selectedCategoryId!,
      dateTime: widget.expense?.dateTime ?? DateTime.now(),
      latitude: _latitude,
      longitude: _longitude,
      locationName: _locationName,
    );

    if (_isEditMode) {
      await _expenseRepository.updateExpense(expense);
    } else {
      await _expenseRepository.insertExpense(expense);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Επεξεργασία εξόδου' : 'Νέο έξοδο'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_categories == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categories!.isEmpty) {
      return _buildNoCategoriesMessage();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            _buildDateSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCategoriesMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.category_outlined, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Πρέπει πρώτα να δημιουργήσεις κατηγορία.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
                _loadCategories();
              },
              icon: const Icon(Icons.add),
              label: const Text('Δημιουργία κατηγορίας'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Ποσό (€)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.euro),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _validateAmount,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Περιγραφή (προαιρετική)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      minLines: 2,
      maxLines: 4,
    );
  }

  Widget _buildCategoryDropdown() {
    return FormField<int>(
      initialValue: _selectedCategoryId,
      validator: (value) => value == null ? 'Επίλεξε κατηγορία' : null,
      builder: (state) => InputDecorator(
        decoration: InputDecoration(
          labelText: 'Κατηγορία',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.category),
          errorText: state.hasError ? state.errorText : null,
        ),
        child: DropdownButton<int>(
          value: _selectedCategoryId,
          isExpanded: true,
          underline: const SizedBox(),
          items: _categories!
              .map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.title)))
              .toList(),
          onChanged: (value) {
            setState(() => _selectedCategoryId = value);
            state.didChange(value);
          },
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    final dt = widget.expense?.dateTime ?? DateTime.now();
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Ημερομηνία / Ώρα',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.access_time),
      ),
      child: Text(AppDateUtils.formatDateTime(dt)),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Τοποθεσία',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey(_locationName),
              initialValue: _locationName,
              decoration: const InputDecoration(
                labelText: 'Όνομα τοποθεσίας (προαιρετικό)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_location_alt),
              ),
              onChanged: (value) {
                _locationName = value.trim().isEmpty ? null : value.trim();
              },
            ),
            const SizedBox(height: 12),
            if (_locationName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _locationName!,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            if (_latitude != null && _longitude != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${_latitude!.toStringAsFixed(5)}, '
                  '${_longitude!.toStringAsFixed(5)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            if (_latitude == null)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Δεν έχει επιλεγεί τοποθεσία.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isFetchingLocation ? null : _loadCurrentLocation,
                icon: _isFetchingLocation
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.location_on),
                label: Text(
                  _isFetchingLocation ? 'Φόρτωση...' : 'Λήψη τοποθεσίας',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : _saveExpense,
      icon: _isSaving
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save),
      label: Text(_isSaving ? 'Αποθήκευση...' : 'Αποθήκευση'),
    );
  }
}
