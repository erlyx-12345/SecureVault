import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/storage_service.dart';
import 'dart:async';

/// AuthViewModel handles all authentication logic (Login, Register, SSO)
/// Implements MVVM pattern - manages state and business logic for auth views
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final BiometricService _biometricService = BiometricService();

  // Authentication state
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _biometricAvailable = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get biometricAvailable => _biometricAvailable;

  /// Initialize ViewModel - check if user is already logged in
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.getCurrentUser();
      _isAuthenticated = _currentUser != null;
      _biometricAvailable = await _biometricService.canCheckBiometrics();
      _clearError();
    } catch (e) {
      _setError('Initialization failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new user with email and password
  Future<bool> registerWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.registerWithEmail(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
      _isAuthenticated = true;
      _clearError();
      return true;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login with email and password
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      _isAuthenticated = true;
      _clearError();
      return true;
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.signInWithGoogle();
      _isAuthenticated = true;
      _clearError();
      print(
        '[AuthViewModel] signInWithGoogle success, currentUser=$_currentUser',
      );
      return true;
    } catch (e) {
      _setError('Google Sign-In failed: ${e.toString()}');
      print('[AuthViewModel] signInWithGoogle error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.signInWithFacebook();
      _isAuthenticated = true;
      _clearError();
      return true;
    } catch (e) {
      _setError('Facebook Sign-In failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Authenticate using biometric (fingerprint/face)
  Future<bool> authenticateWithBiometric() async {
    if (!_biometricAvailable) {
      _setError('Biometric authentication is not available on this device');
      return false;
    }

    try {
      final isAuthenticated = await _biometricService.authenticate();
      if (isAuthenticated) {
        _clearError();
        return true;
      } else {
        _setError('Biometric authentication failed');
        return false;
      }
    } catch (e) {
      _setError('Biometric error: ${e.toString()}');
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? bio,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) {
      _setError('No user logged in');
      return false;
    }

    _setLoading(true);
    try {
      _currentUser = await _authService.updateUserProfile(
        uid: _currentUser!.uid,
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
      _setLoading(false);
    }
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    if (_currentUser == null) {
      _setError('No user logged in');
      return;
    }

    try {
      await _storageService.setBiometricEnabled(enabled);
      _currentUser = _currentUser!.copyWith(biometricEnabled: enabled);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to update biometric settings: ${e.toString()}');
    }
  }

  /// Logout user
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _clearError();
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
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

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  StreamSubscription<UserModel?>? _authSub;

  AuthViewModel() {
    // Listen to Firebase auth state changes as a fallback for SSO flows
    _authSub = _authService.authStateStream.listen((user) {
      _currentUser = user;
      _isAuthenticated = user != null;
      _clearError();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
