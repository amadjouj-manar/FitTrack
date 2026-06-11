import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  User? _currentUser;
  int _caloriesDuJour = 0;
  int _totalSeances = 0;
  bool _isLoading = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _loadDashboardData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }



  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null && user.id != null) {
        final now = DateTime.now();
        final dateStr =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        
        final calories = await DbService.instance.getCaloriesDuJour(user.id!, dateStr);
        final seances = await DbService.instance.getWorkoutsByUser(user.id!);
        
        setState(() {
          _currentUser = user;
          _caloriesDuJour = calories;
          _totalSeances = seances.length;
        });
        _animController.forward(from: 0);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 48),
                      _buildCaloriesProgress(),
                      const SizedBox(height: 32),
                      _buildStatCards(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    final nom = _currentUser?.nom ?? 'Utilisateur';
    return Text(
      'Bonjour, $nom ! 👋\nVoici votre résumé du jour.',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCaloriesProgress() {
    // Si l'utilisateur n'a pas d'objectif, on met 2000 par défaut
    final objectif = _currentUser?.objectifCalories ?? 2000.0;
    final double progress = (_caloriesDuJour / objectif).clamp(0.0, 1.0);
    final isSuccess = progress >= 1.0;
    
    return Column(
      children: [
        const Text(
          'Objectif Calorique',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 220,
              width: 220,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 16,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                color: isSuccess ? Colors.green : Theme.of(context).colorScheme.primary,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department, 
                  size: 56, 
                  color: isSuccess ? Colors.green : Colors.orange
                ),
                const SizedBox(height: 8),
                Text(
                  '$_caloriesDuJour',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Text(
                  '/ ${objectif.toInt()} kcal',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          isSuccess 
              ? 'Objectif atteint, félicitations ! 🎉' 
              : 'Continuez vos efforts ! 💪',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: isSuccess ? Colors.green : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.directions_run,
            value: '$_totalSeances',
            label: 'Séances\ntotales',
            iconColor: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            icon: Icons.local_fire_department,
            value: '$_caloriesDuJour',
            label: 'Kcal\naujourd\'hui',
            iconColor: Colors.orange,
          ),
        ),
      ],
    );
  }
}
