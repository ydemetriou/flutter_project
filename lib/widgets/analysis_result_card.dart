import 'package:flutter/material.dart';

import '../models/expense_summary.dart';
import '../utils/money_utils.dart';

class AnalysisResultCard extends StatelessWidget {
  final ExpenseSummary summary;
  final int index;

  const AnalysisResultCard({
    super.key,
    required this.summary,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(summary.categoryTitle),
        trailing: Text(
          MoneyUtils.formatEuro(summary.totalAmount),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
