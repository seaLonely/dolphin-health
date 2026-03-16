class WeightRecord {
  final int? id;
  final double weight;
  final DateTime date;
  final String? note;

  WeightRecord({
    this.id,
    required this.weight,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory WeightRecord.fromMap(Map<String, dynamic> map) {
    return WeightRecord(
      id: map['id'],
      weight: map['weight'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}
