import 'package:flutter/material.dart';
import '../../models/workout.dart';
import '../../services/db_service.dart';

class WorkoutFormScreen extends StatefulWidget {
  final Workout? workout;
  final int userId;

  const WorkoutFormScreen({super.key, this.workout, required this.userId});

  @override
  State<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends State<WorkoutFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _dureeCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.workout != null) {
      _nomCtrl.text = widget.workout!.nom;
      _dureeCtrl.text = widget.workout!.dureeMinutes.toString();
      _caloriesCtrl.text = widget.workout!.calories.toString();
      try {
        _selectedDate = DateTime.parse(widget.workout!.date);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _dureeCtrl.dispose();
    _caloriesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String dateStr =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      final workout = Workout(
        id: widget.workout?.id,
        userId: widget.userId,
        nom: _nomCtrl.text.trim(),
        dureeMinutes: int.parse(_dureeCtrl.text.trim()),
        calories: int.parse(_caloriesCtrl.text.trim()),
        date: dateStr,
      );

      if (widget.workout == null) {
        await DbService.instance.insertWorkout(workout);
      } else {
        await DbService.instance.updateWorkout(workout);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.workout != null;
    final dateStr =
        "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la séance' : 'Nouvelle séance'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nom (ex: Course à pied)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_run),
                      ),
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dureeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Durée (minutes)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timer),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Requis';
                        if (int.tryParse(val) == null) return 'Nombre invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _caloriesCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Calories brûlées',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_fire_department),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Requis';
                        if (int.tryParse(val) == null) return 'Nombre invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date de la séance'),
                      subtitle: Text(dateStr),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveWorkout,
                        icon: const Icon(Icons.save),
                        label: Text(isEditing ? 'Enregistrer' : 'Ajouter'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
