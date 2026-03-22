import 'package:shared_preferences/shared_preferences.dart';

/// Central place for all local device preferences.
/// Add new keys here as the app grows.
class AppPreferences {
  AppPreferences._(); // prevent instantiation

  // ── KEYS 
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyTheme = 'dark_mode';
  static const _keyLastLocation = 'last_location';

  // ── ONBOARDING 

  /// Returns true if the user has already seen the onboarding screens.
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingSeen) ?? false;
  }

  /// Call this once when the user finishes or skips onboarding.
  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingSeen, true);
  }

  // ── THEME 

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTheme) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTheme, value);
  }

  // ── LOCATION 

  /// Last location the user set (cached locally for instant display).
  static Future<String> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastLocation) ?? '';
  }

  static Future<void> setLastLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastLocation, location);
  }

  // ── CLEAR ALL (used on logout / account delete) 

  /// Clears all local preferences except onboarding flag.
  /// Call this on logout so the next user starts fresh.
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTheme);
    await prefs.remove(_keyLastLocation);
    // intentionally keep _keyOnboardingSeen so onboarding doesn't show again
  }

  /// Full reset — clears everything including onboarding flag.
  /// Use only for testing or account deletion.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}