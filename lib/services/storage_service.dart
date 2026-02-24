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
}
