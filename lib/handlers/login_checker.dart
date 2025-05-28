import 'package:shared_preferences/shared_preferences.dart';

class LoginChecker {
  static const String _loginFlagKey = 'is_logged_in';

  /// Returns true if user is logged in, false otherwise.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginFlagKey) ?? false;
  }

  /// Sets the login flag (true after login, false on logout).
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginFlagKey, value);
  }
}
