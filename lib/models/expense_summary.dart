class ExpenseSummary {
  final String categoryTitle;
  final double totalAmount;

  ExpenseSummary({required this.categoryTitle, required this.totalAmount});

  factory ExpenseSummary.fromMap(Map<String, dynamic> map) {
    return ExpenseSummary(
      categoryTitle: map['categoryTitle'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'ExpenseSummary(categoryTitle: $categoryTitle, totalAmount: $totalAmount)';
  }
}
