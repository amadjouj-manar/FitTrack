// lib/services/db_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/user.dart';
import '../models/workout.dart';
import '../models/weight_entry.dart';

class DbService {
  // ----- Singleton : une seule instance de la base pour toute l'app -----
  static final DbService instance = DbService._internal();
  DbService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'fittrack.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ---------- Table users ----------
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        mot_de_passe TEXT NOT NULL,
        poids_initial REAL,
        objectif_calories REAL
      )
    ''');

    // ---------- Table workouts ----------
    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nom TEXT NOT NULL,
        duree_minutes INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // ---------- Table weight_entries ----------
    await db.execute('''
      CREATE TABLE weight_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        poids REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // =====================================================================
  // ============================ USERS =================================
  // =====================================================================

  /// Inscription. Retourne l'utilisateur créé (avec son id).
  /// Lève une Exception si l'email existe déjà.
  Future<User> registerUser(User user) async {
    final db = await database;

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [user.email],
    );
    if (existing.isNotEmpty) {
      throw Exception('Un compte existe déjà avec cet email.');
    }

    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  /// Connexion. Retourne l'utilisateur si email/mot de passe correspondent,
  /// sinon retourne null.
  Future<User?> loginUser(String email, String motDePasse) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND mot_de_passe = ?',
      whereArgs: [email, motDePasse],
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  /// Met à jour les infos du profil (nom, poids initial, objectif calories...)
  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // =====================================================================
  // ========================== WORKOUTS ================================
  // =====================================================================

  Future<Workout> insertWorkout(Workout workout) async {
    final db = await database;
    final id = await db.insert('workouts', workout.toMap());
    return Workout(
      id: id,
      userId: workout.userId,
      nom: workout.nom,
      dureeMinutes: workout.dureeMinutes,
      calories: workout.calories,
      date: workout.date,
    );
  }

  /// Toutes les séances d'un utilisateur, les plus récentes en premier
  Future<List<Workout>> getWorkoutsByUser(int userId) async {
    final db = await database;
    final rows = await db.query(
      'workouts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map((row) => Workout.fromMap(row)).toList();
  }

  Future<void> updateWorkout(Workout workout) async {
    final db = await database;
    await db.update(
      'workouts',
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<void> deleteWorkout(int id) async {
    final db = await database;
    await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  /// Total des calories brûlées aujourd'hui pour un utilisateur (dashboard)
  Future<int> getCaloriesDuJour(int userId, String date) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(calories), 0) AS total
      FROM workouts
      WHERE user_id = ? AND date = ?
    ''', [userId, date]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // =====================================================================
  // ======================== WEIGHT ENTRIES ============================
  // =====================================================================

  Future<WeightEntry> insertWeightEntry(WeightEntry entry) async {
    final db = await database;
    final id = await db.insert('weight_entries', entry.toMap());
    return WeightEntry(
      id: id,
      userId: entry.userId,
      poids: entry.poids,
      date: entry.date,
    );
  }

  /// Historique de poids, du plus ancien au plus récent (pour un graphique)
  Future<List<WeightEntry>> getWeightEntriesByUser(int userId) async {
    final db = await database;
    final rows = await db.query(
      'weight_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date ASC, id ASC',
    );
    return rows.map((row) => WeightEntry.fromMap(row)).toList();
  }

  Future<void> deleteWeightEntry(int id) async {
    final db = await database;
    await db.delete('weight_entries', where: 'id = ?', whereArgs: [id]);
  }
}