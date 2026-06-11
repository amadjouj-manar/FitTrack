// lib/models/weight_entry.dart

class WeightEntry {
  final int? id;
  final int userId;
  final double poids; // en kg
  final String date; // format "yyyy-MM-dd"

  const WeightEntry({
    this.id,
    required this.userId,
    required this.poids,
    required this.date,
  });

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      poids: (map['poids'] as num).toDouble(),
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'poids': poids,
      'date': date,
    };
  }
}