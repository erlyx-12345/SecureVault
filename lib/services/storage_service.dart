import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import '../models/user_model.dart';

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

  // SharedPreferences methods for login and biometric flags
  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isloggedin', value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isloggedin') ?? false;
  }

  Future<void> setBiometricEnabledFlag(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isbiometricenabled', value);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isbiometricenabled') ?? false;
  }

  Future<void> clearAuthPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isloggedin', false);
    await prefs.setBool('isbiometricenabled', false);
  }

  // Save a snapshot of the user profile (secure) so biometric login can
  // restore profile info when Firebase session is not available.
  Future<void> saveUserProfile(UserModel user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _storage.write(key: 'saved_user_profile', value: jsonStr);
  }

  Future<UserModel?> getSavedUserProfile() async {
    final jsonStr = await _storage.read(key: 'saved_user_profile');
    if (jsonStr == null) return null;
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteSavedUserProfile() async {
    await _storage.delete(key: 'saved_user_profile');
  }
}
