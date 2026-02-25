import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// ProfileViewModel handles user profile state and operations
/// Implements MVVM pattern - manages profile data and updates
class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _biometricEnabled = false;
  bool _isSaving = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get biometricEnabled => _biometricEnabled;
  bool get isSaving => _isSaving;

  String get displayName => _user?.fullName ?? 'User';
  String get email => _user?.email ?? '';
  String get firstName => _user?.firstName ?? '';
  String get lastName => _user?.lastName ?? '';
  String? get bio => _user?.bio;
  String? get profileImageUrl => _user?.profileImageUrl;

  /// Initialize ProfileViewModel with user data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _user = await _authService.getCurrentUser();
      if (_user != null) {
        _biometricEnabled = await _storageService.getBiometricEnabled();
      }
      _clearError();
    } catch (e) {
      _setError('Failed to load profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? bio,
    String? profileImageUrl,
  }) async {
    if (_user == null) {
      _setError('No user logged in');
      return false;
    }

    _setSaving(true);
    try {
      _user = await _authService.updateUserProfile(
        uid: _user!.uid,
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        profileImageUrl: profileImageUrl,
      );
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  /// Update first name only
  void updateFirstName(String firstName) {
    if (_user != null) {
      _user = _user!.copyWith(firstName: firstName);
      notifyListeners();
    }
  }

  /// Update last name only
  void updateLastName(String lastName) {
    if (_user != null) {
      _user = _user!.copyWith(lastName: lastName);
      notifyListeners();
    }
  }

  /// Update bio
  void updateBio(String bio) {
    if (_user != null) {
      _user = _user!.copyWith(bio: bio);
      notifyListeners();
    }
  }

  /// Update profile image URL
  void updateProfileImage(String imageUrl) {
    if (_user != null) {
      _user = _user!.copyWith(profileImageUrl: imageUrl);
      notifyListeners();
    }
  }

  /// Toggle biometric authentication
  Future<void> toggleBiometric(bool enabled) async {
    try {
      await _storageService.setBiometricEnabled(enabled);
      _biometricEnabled = enabled;
      if (_user != null) {
        _user = _user!.copyWith(biometricEnabled: enabled);
      }
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update biometric settings: ${e.toString()}');
    }
  }

  /// Refresh profile data from server
  Future<void> refreshProfile() async {
    _setLoading(true);
    try {
      _user = await _authService.getCurrentUser();
      _clearError();
    } catch (e) {
      _setError('Failed to refresh profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // ========== Private Helper Methods ==========

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set saving state
  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }
}
