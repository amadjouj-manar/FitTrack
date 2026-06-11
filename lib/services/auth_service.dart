// lib/services/auth_service.dart
import '../models/user.dart';
import 'db_service.dart';
import 'prefs_service.dart';

class AuthService {
  final DbService _db = DbService.instance;
  final PrefsService _prefs = PrefsService();

  /// Inscription : crée le compte puis ouvre directement la session
  Future<User> register({
    required String nom,
    required String email,
    required String motDePasse,
  }) async {
    final user = User(nom: nom, email: email, motDePasse: motDePasse);
    final created = await _db.registerUser(user);
    await _prefs.saveUserId(created.id!);
    return created;
  }

  /// Connexion : retourne l'utilisateur si les identifiants sont corrects
  /// ou lève une Exception sinon.
  Future<User> login({
    required String email,
    required String motDePasse,
  }) async {
    final user = await _db.loginUser(email, motDePasse);
    if (user == null) {
      throw Exception('Email ou mot de passe incorrect.');
    }
    await _prefs.saveUserId(user.id!);
    return user;
  }

  Future<void> logout() async {
    await _prefs.clearSession();
  }

  /// Retourne l'utilisateur actuellement connecté, ou null si aucune session
  Future<User?> getCurrentUser() async {
    final id = await _prefs.getUserId();
    if (id == null) return null;
    return _db.getUserById(id);
  }
}