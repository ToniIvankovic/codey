import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemeService extends ChangeNotifier {
  ThemeMode get mode;
  Future<void> setMode(ThemeMode mode);
  Future<void> load();
}

class ThemeServiceImpl extends ChangeNotifier implements ThemeService {
  static const _prefsKey = 'themeMode';

  ThemeMode _mode = ThemeMode.light;

  ThemeServiceImpl() {
    load();
  }

  @override
  ThemeMode get mode => _mode;

  @override
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    final loaded = _decode(stored);
    if (loaded != _mode) {
      _mode = loaded;
      notifyListeners();
    }
  }

  @override
  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _encode(mode));
  }

  static ThemeMode _decode(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }
}
