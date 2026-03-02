import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/storage_service.dart';
import 'dart:async';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final BiometricService _biometricService = BiometricService();

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _biometricAvailable = false;

  Duration _sessionDuration = const Duration(minutes: 5);
  Timer? _sessionTimer;

  AuthCredential? _pendingFacebookCredential;
  List<String>? _pendingEmailProviders;
  String? _pendingEmail;

  AuthCredential? get pendingFacebookCredential => _pendingFacebookCredential;
  List<String>? get pendingEmailProviders => _pendingEmailProviders;
  String? get pendingEmail => _pendingEmail;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get biometricAvailable => _biometricAvailable;

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

      _startSessionTimer();
      _clearError();
      return true;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

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

      if (_pendingFacebookCredential != null) {
        try {
          await _authService.linkCredential(_pendingFacebookCredential!);
          _pendingFacebookCredential = null;
          _pendingEmailProviders = null;
          _pendingEmail = null;
        } catch (e) {
          print('[AuthViewModel] linking after email login failed: $e');
        }
      }
      _clearError();
      return true;
    } catch (e) {
      String message;

      if (e is Exception) {
        message = e.toString().replaceFirst('Exception: ', '');
      } else {
        message = e.toString();
      }
      _setError(message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email: email);
      _clearError();
      return true;
    } catch (e) {
      String message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      _setError(message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.signInWithGoogle();
      _isAuthenticated = true;
      // link any pending facebook credential
      if (_pendingFacebookCredential != null) {
        try {
          await _authService.linkCredential(_pendingFacebookCredential!);
          _pendingFacebookCredential = null;
          _pendingEmailProviders = null;
          _pendingEmail = null;
        } catch (e) {
          print('[AuthViewModel] linking after Google login failed: $e');
        }
      }
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

  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    try {
      // clear any previous conflict state
      _pendingFacebookCredential = null;
      _pendingEmailProviders = null;
      _pendingEmail = null;

      _currentUser = await _authService.signInWithFacebook();
      _isAuthenticated = true;
      // start session timeout
      _startSessionTimer();
      _clearError();
      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.toLowerCase().contains('cancel')) {
        // user cancelled the Facebook flow; don't display error
        _clearError();
        return false;
      }
      if (e is FirebaseAuthException &&
          e.code == 'account-exists-with-different-credential' &&
          e.email != null) {
        // capture conflict state for UI to resolve
        _pendingFacebookCredential = e.credential;
        _pendingEmail = e.email;
        _pendingEmailProviders = await _authService.fetchSignInMethodsForEmail(
          e.email!,
        );
        _setError(
          'An account already exists for ${e.email}. Please sign in with one of the listed providers to link Facebook.',
        );
        return false;
      }
      _setError('Facebook Sign-In failed: $msg');
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
        // after successful local auth, try to fetch current Firebase user
        _currentUser = await _authService.getCurrentUser();
        if (_currentUser == null) {
          // fallback to a saved local snapshot of the profile (if available)
          final saved = await _storageService.getSavedUserProfile();
          if (saved != null) {
            _currentUser = saved;
            // treat as authenticated because biometric validated the device
            _isAuthenticated = true;
          } else {
            _isAuthenticated = false;
          }
        } else {
          _isAuthenticated = true;
          // refresh and save the user profile snapshot for future offline access
          try {
            await _storageService.saveUserProfile(_currentUser!);
          } catch (_) {
            // if saving fails, continue anyway - user is authenticated
          }
        }
        _clearError();
        _startSessionTimer();
        notifyListeners();
        return true;
      } else {
        // user cancelled or failed biometric - do not treat as an error
        _clearError();
        return false;
      }
    } catch (e) {
      _setError('Biometric error: ${e.toString()}');
      return false;
    }
  }

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

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      // cancel any running session timer
      _cancelSessionTimer();
      _clearError();
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void setSessionDuration(Duration d) {
    _sessionDuration = d;
    // restart timer if user is authenticated
    if (_isAuthenticated) {
      _startSessionTimer();
    }
  }

  void _startSessionTimer() {
    _cancelSessionTimer();
    _sessionTimer = Timer(_sessionDuration, () {
      _setError('Session expired. Please sign in again.');
      logout();
    });
  }


  void _cancelSessionTimer() {
    try {
      _sessionTimer?.cancel();
    } catch (_) {}
    _sessionTimer = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() => _clearError();

  StreamSubscription<UserModel?>? _authSub;

  AuthViewModel() {
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
