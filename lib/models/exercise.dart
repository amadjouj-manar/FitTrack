// lib/models/exercise.dart

class Exercise {
  final String? id; // string car les API REST (MockAPI) renvoient souvent des id en string
  final String nom;
  final String categorie; // ex: Cardio, Musculation, Yoga...
  final String description;
  final String? image; // URL de l'image (optionnelle)

  const Exercise({
    this.id,
    required this.nom,
    required this.categorie,
    required this.description,
    this.image,
  });

  // fromJson : MockAPI -> objet Dart
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id']?.toString(),
      nom: json['nom'] as String,
      categorie: json['categorie'] as String,
      description: json['description'] as String? ?? '',
      image: json['image'] as String?,
    );
  }

  // toJson : objet Dart -> JSON (pour un éventuel POST)
  Map<String, dynamic> toJson() => {
        'nom': nom,
        'categorie': categorie,
        'description': description,
        if (image != null) 'image': image,
      };
}