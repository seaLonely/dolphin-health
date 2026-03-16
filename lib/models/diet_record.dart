class DietRecord {
  final int? id;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime date;
  final String? mealType; // breakfast, lunch, dinner, snack

  DietRecord({
    this.id,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.date,
    this.mealType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'date': date.toIso8601String(),
      'mealType': mealType,
    };
  }

  factory DietRecord.fromMap(Map<String, dynamic> map) {
    return DietRecord(
      id: map['id'],
      foodName: map['foodName'],
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'],
      fat: map['fat'],
      date: DateTime.parse(map['date']),
      mealType: map['mealType'],
    );
  }
}
