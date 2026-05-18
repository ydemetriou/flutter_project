class Expense {
  final int? id;
  final double amount;
  final String? description;
  final int categoryId;
  final DateTime dateTime;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  Expense({
    this.id,
    required this.amount,
    this.description,
    required this.categoryId,
    required this.dateTime,
    this.latitude,
    this.longitude,
    this.locationName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category_id': categoryId,
      'date_time': dateTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      categoryId: map['category_id'] as int,
      dateTime: DateTime.parse(map['date_time'] as String),
      latitude: map['latitude'] == null
          ? null
          : (map['latitude'] as num).toDouble(),
      longitude: map['longitude'] == null
          ? null
          : (map['longitude'] as num).toDouble(),
      locationName: map['location_name'] as String?,
    );
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? description,
    int? categoryId,
    DateTime? dateTime,
    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      dateTime: dateTime ?? this.dateTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, amount: $amount, description: $description, '
        'categoryId: $categoryId, dateTime: $dateTime, latitude: $latitude, '
        'longitude: $longitude, locationName: $locationName)';
  }
}
