// lib/services/prefs_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String _keyUserId = 'connected_user_id';
  static const String _keyDarkMode = 'dark_mode';

  // ----------------- Session -----------------

  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  /// Retourne l'id de l'utilisateur connecté, ou null si personne n'est connecté
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }

  // ----------------- Dark mode -----------------

  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }
}