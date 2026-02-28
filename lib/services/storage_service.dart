import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/constants.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppStrings.secureTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: AppStrings.secureTokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: AppStrings.secureTokenKey);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: AppStrings.biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  Future<bool> getBiometricEnabled() async {
    final value = await _storage.read(key: AppStrings.biometricEnabledKey);
    return value == 'true';
  }

  // Bio saved per user
  Future<void> saveUserBio(String userId, String bio) async {
    final key = 'user_${userId}_bio';
    await _storage.write(key: key, value: bio);
  }

  Future<String?> getUserBio(String userId) async {
    final key = 'user_${userId}_bio';
    return _storage.read(key: key);
  }

  // Theme preference saved per user
  Future<void> saveThemePreference(String userId, bool isDarkMode) async {
    final key = 'user_${userId}_theme';
    await _storage.write(key: key, value: isDarkMode ? 'true' : 'false');
  }

  Future<bool?> getThemePreference(String userId) async {
    final key = 'user_${userId}_theme';
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return value == 'true';
  }
}
