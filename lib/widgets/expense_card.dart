import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../utils/app_date_utils.dart';
import '../utils/money_utils.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final String categoryName;
  final VoidCallback onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.categoryName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.euro, color: Colors.green),
        ),
        title: Text(
          MoneyUtils.formatEuro(expense.amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(categoryName),
            if (expense.description != null && expense.description!.isNotEmpty)
              Text(
                expense.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            Text(
              AppDateUtils.formatDateTime(expense.dateTime),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
