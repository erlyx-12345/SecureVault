import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeViewModel extends ChangeNotifier {
  static const _key = 'isDarkMode';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  ThemeViewModel();

  Future<void> loadTheme() async {
    try {
      final val = await _storage.read(key: _key);
      if (val != null) {
        _isDarkMode = val.toLowerCase() == 'true';
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    try {
      await _storage.write(key: _key, value: value ? 'true' : 'false');
    } catch (_) {}
  }
}
