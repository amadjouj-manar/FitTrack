// lib/models/workout.dart

class Workout {
  final int? id;
  final int userId; // lien vers l'utilisateur connecté
  final String nom; // ex: "Course à pied", "Musculation - Pectoraux"
  final int dureeMinutes;
  final int calories;
  final String date; // format "yyyy-MM-dd"

  const Workout({
    this.id,
    required this.userId,
    required this.nom,
    required this.dureeMinutes,
    required this.calories,
    required this.date,
  });

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      nom: map['nom'] as String,
      dureeMinutes: map['duree_minutes'] as int,
      calories: map['calories'] as int,
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'nom': nom,
      'duree_minutes': dureeMinutes,
      'calories': calories,
      'date': date,
    };
  }
}