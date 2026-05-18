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
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          alignment: Alignment.center,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(summary.categoryTitle),
        trailing: Text(
          MoneyUtils.formatEuro(summary.totalAmount),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
