import 'package:flutter/material.dart';

import '../../models/expense_summary.dart';
import '../../repositories/expense_repository.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/analysis_result_card.dart';

class ExpenseAnalysisScreen extends StatefulWidget {
  const ExpenseAnalysisScreen({super.key});

  @override
  State<ExpenseAnalysisScreen> createState() => _ExpenseAnalysisScreenState();
}

class _ExpenseAnalysisScreenState extends State<ExpenseAnalysisScreen> {
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  DateTime? _startDate;
  DateTime? _endDate;
  List<ExpenseSummary> _results = [];

  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _selectStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selectedDate == null) return;
    setState(() => _startDate = selectedDate);
  }

  Future<void> _selectEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selectedDate == null) return;
    setState(() => _endDate = selectedDate);
  }

  Future<void> _analyzeExpenses() async {
    if (_startDate == null || _endDate == null) {
      SnackbarUtils.showMessage(
        context,
        'Πρέπει να επιλέξεις ημερομηνία έναρξης και λήξης.',
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      SnackbarUtils.showMessage(
        context,
        'Η ημερομηνία έναρξης δεν μπορεί να είναι μετά τη λήξη.',
      );
      return;
    }

    final adjustedEndDate = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      23,
      59,
      59,
    );

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final results = await _expenseRepository.getExpenseAnalysis(
      startDate: _startDate!,
      endDate: adjustedEndDate,
    );

    if (!mounted) return;

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Δεν έχει επιλεγεί';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ανάλυση εξόδων')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDateSelectors(),
            const SizedBox(height: 16),
            _buildAnalyzeButton(),
            const SizedBox(height: 16),
            Expanded(child: _buildResultsArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectors() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text('Ημερομηνία έναρξης'),
            subtitle: Text(_formatDate(_startDate)),
            onTap: _selectStartDate,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Ημερομηνία λήξης'),
            subtitle: Text(_formatDate(_endDate)),
            onTap: _selectEndDate,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _analyzeExpenses,
        icon: const Icon(Icons.analytics),
        label: const Text('Ανάλυση'),
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return const Center(
        child: Text(
          'Επίλεξε περίοδο και πάτησε Ανάλυση.',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Text(
          'Δεν βρέθηκαν έξοδα για την επιλεγμένη περίοδο.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        return AnalysisResultCard(summary: _results[index], index: index);
      },
    );
  }
}
