// lib/models/user.dart

class User {
  final int? id;
  final String nom;
  final String email;
  final String motDePasse;
  final double? poidsInitial; // en kg, optionnel
  final double? objectifCalories; // objectif quotidien

  const User({
    this.id,
    required this.nom,
    required this.email,
    required this.motDePasse,
    this.poidsInitial,
    this.objectifCalories,
  });

  // Conversion depuis une ligne SQLite (Map) vers un objet User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      email: map['email'] as String,
      motDePasse: map['mot_de_passe'] as String,
      poidsInitial: map['poids_initial'] != null
          ? (map['poids_initial'] as num).toDouble()
          : null,
      objectifCalories: map['objectif_calories'] != null
          ? (map['objectif_calories'] as num).toDouble()
          : null,
    );
  }

  // Conversion depuis un objet User vers une Map (pour insertion SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'email': email,
      'mot_de_passe': motDePasse,
      'poids_initial': poidsInitial,
      'objectif_calories': objectifCalories,
    };
  }

  // Utile pour mettre à jour certains champs sans tout réécrire
  User copyWith({
    int? id,
    String? nom,
    String? email,
    String? motDePasse,
    double? poidsInitial,
    double? objectifCalories,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      motDePasse: motDePasse ?? this.motDePasse,
      poidsInitial: poidsInitial ?? this.poidsInitial,
      objectifCalories: objectifCalories ?? this.objectifCalories,
    );
  }
}