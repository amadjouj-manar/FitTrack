import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import '../../services/exercise_api_service.dart';

class ExerciseFormScreen extends StatefulWidget {
  final Exercise? exercise;

  const ExerciseFormScreen({super.key, this.exercise});

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _categorieCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  final ExerciseApiService _apiService = ExerciseApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _nomCtrl.text = widget.exercise!.nom;
      _categorieCtrl.text = widget.exercise!.categorie;
      _descCtrl.text = widget.exercise!.description;
      if (widget.exercise!.image != null) {
        _imageCtrl.text = widget.exercise!.image!;
      }
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _categorieCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newExercise = Exercise(
        id: widget.exercise?.id,
        nom: _nomCtrl.text.trim(),
        categorie: _categorieCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        image: _imageCtrl.text.trim().isNotEmpty ? _imageCtrl.text.trim() : null,
      );

      if (widget.exercise == null) {
        // Création
        await _apiService.createExercise(newExercise);
      } else {
        // Mise à jour
        await _apiService.updateExercise(newExercise);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true); // Retourne true pour signaler le succès
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.exercise != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier l\'exercice' : 'Nouvel exercice'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'exercice',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categorieCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie (ex: Cardio, Musculation...)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer une catégorie';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'URL de l\'image (Optionnelle)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: Text(isEditing ? 'Enregistrer' : 'Ajouter'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _saveExercise,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
