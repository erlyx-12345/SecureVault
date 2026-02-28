import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _isDarkMode = true;
  String? _userId;

  bool get isDarkMode => _isDarkMode;

  ThemeViewModel();

  /// Load theme preference for a specific user
  Future<void> loadTheme(String? userId) async {
    _userId = userId;
    if (_userId == null) return;

    try {
      final isDarkMode = await _storageService.getThemePreference(_userId!);
      if (isDarkMode != null) {
        _isDarkMode = isDarkMode;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Toggle theme and save preference for current user
  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    if (_userId == null) return;

    try {
      await _storageService.saveThemePreference(_userId!, value);
    } catch (_) {}
  }

  /// Update userId (call when user logs in)
  Future<void> setUserId(String userId) async {
    _userId = userId;
    await loadTheme(userId);
  }
}
