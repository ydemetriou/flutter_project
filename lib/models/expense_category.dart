class ExpenseCategory {
  final int? id;
  final String title;
  final String? description;

  ExpenseCategory({this.id, required this.title, this.description});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'description': description};
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
    );
  }

  ExpenseCategory copyWith({int? id, String? title, String? description}) {
    return ExpenseCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'ExpenseCategory(id: $id, title: $title, description: $description)';
  }
}
