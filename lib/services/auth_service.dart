/// Auth Service untuk mengelola session login admin
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Keys untuk shared preferences
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyAdminUsername = 'admin_username';
  static const String _keyLoginTime = 'login_time';

  /// Check apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Get username admin yang login
  static Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAdminUsername);
  }

  /// Set login session
  static Future<void> setLogin(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyAdminUsername, username);
    await prefs.setString(_keyLoginTime, DateTime.now().toIso8601String());
  }

  /// Clear login session (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyAdminUsername);
    await prefs.remove(_keyLoginTime);
  }

  /// Clear all data (untuk reset)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
