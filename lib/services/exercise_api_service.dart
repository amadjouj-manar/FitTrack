import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exercise.dart';

class ExerciseApiService {
  // L'URL de base pour json-server sur l'émulateur Android
  // Si vous utilisez un appareil physique, remplacez 10.0.2.2 par l'IP de votre PC.
  static const String baseUrl = 'http://10.0.2.2:3000/exercices';

  // Récupérer tous les exercices (READ)
  Future<List<Exercise>> getExercises() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Erreur de chargement des exercices');
      }
    } catch (e) {
      throw Exception('Erreur réseau lors du chargement: $e');
    }
  }

  // Créer un nouvel exercice (CREATE)
  Future<Exercise> createExercise(Exercise exercise) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(exercise.toJson()),
      );
      if (response.statusCode == 201) {
        return Exercise.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur lors de la création de l\'exercice');
      }
    } catch (e) {
      throw Exception('Erreur réseau lors de la création: $e');
    }
  }

  // Mettre à jour un exercice existant (UPDATE)
  Future<Exercise> updateExercise(Exercise exercise) async {
    if (exercise.id == null) {
      throw Exception("Impossible de mettre à jour un exercice sans ID");
    }
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${exercise.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(exercise.toJson()),
      );
      if (response.statusCode == 200) {
        return Exercise.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur lors de la mise à jour de l\'exercice');
      }
    } catch (e) {
      throw Exception('Erreur réseau lors de la mise à jour: $e');
    }
  }

  // Supprimer un exercice (DELETE)
  Future<void> deleteExercise(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      // json-server retourne souvent 200 pour le delete
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression de l\'exercice');
      }
    } catch (e) {
      throw Exception('Erreur réseau lors de la suppression: $e');
    }
  }
}
