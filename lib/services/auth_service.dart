import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

/// Clean, single-file AuthService
/// Supports: Email/Password, Google, Facebook via Firebase
class AuthService {
  // singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Use the Web (server) client ID so GoogleSignIn returns an ID token
    // required by FirebaseAuth when signing in with credentials.
    clientId: AppStrings.googleWebClientId,
  );
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final StorageService _storage = StorageService();

  // ---------------- Email/Password ----------------
  Future<UserModel> registerWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) throw Exception('Registration failed');

      await user.updateDisplayName('$firstName $lastName');
      await user.reload();

      final token = await user.getIdToken();
      if (token != null) await _storage.saveToken(token);

      return _toUserModel(user);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) throw Exception('Login failed');

      final token = await user.getIdToken();
      if (token != null) await _storage.saveToken(token);

      return _toUserModel(user);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  // ---------------- Google ----------------
  Future<UserModel> signInWithGoogle() async {
    try {
      // Sign out first to force account picker
      print('[AuthService] Google sign-out (pre)');
      await _googleSignIn.signOut();
      print('[AuthService] Google sign-out done');

      final googleUser = await _googleSignIn.signIn();
      print('[AuthService] googleUser: $googleUser');
      if (googleUser == null) {
        print('[AuthService] Google Sign-In cancelled (googleUser == null)');
        throw Exception('Google Sign-In cancelled');
      }

      final googleAuth = await googleUser.authentication;
      print(
        '[AuthService] googleAuth: accessToken=${googleAuth.accessToken != null}, idToken=${googleAuth.idToken != null}',
      );
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print(
          '[AuthService] Missing tokens: access=${googleAuth.accessToken}, id=${googleAuth.idToken}',
        );
        throw Exception('Failed to obtain Google authentication tokens');
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('[AuthService] Created Google credential');

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception('Google Sign-In failed');

      final token = await user.getIdToken();
      if (token != null) await _storage.saveToken(token);

      return _toUserModel(user);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Google Sign-In error: ${e.toString()}');
    }
  }

  // ---------------- Facebook ----------------
  Future<UserModel> signInWithFacebook() async {
    try {
      // 🔥 Ensure plugin channel is ready (fix for MIUI / Android 15)
      await Future.delayed(const Duration(milliseconds: 500));

      // 🔥 Reset any previous sessions (important on MIUI)
      await _facebookAuth.logOut();

      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
        loginBehavior: LoginBehavior.webOnly,
        loginTracking: LoginTracking.enabled,
      );

      if (result.status == LoginStatus.cancelled) {
        throw Exception('Facebook Sign-In cancelled');
      }

      if (result.status == LoginStatus.failed) {
        throw Exception('Facebook Sign-In failed: ${result.message}');
      }

      final accessToken = result.accessToken;
      if (accessToken == null || accessToken.tokenString.isEmpty) {
        throw Exception('No Facebook access token');
      }

      final credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception('Facebook Sign-In failed');

      final token = await user.getIdToken();
      if (token != null) await _storage.saveToken(token);

      return _toUserModel(user);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Facebook Sign-In error: ${e.toString()}');
    }
  }

  // ---------------- User management ----------------
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final token = await user.getIdToken();
    if (token != null) await _storage.saveToken(token);
    return _toUserModel(user);
  }

  Future<void> logout() async {
    await _auth.signOut();
    // Sign out from Google and Facebook as well
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await _facebookAuth.logOut();
    } catch (_) {}
    await _storage.clearToken();
  }

  Future<UserModel> updateUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    String? bio,
    String? profileImageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != uid) {
      throw Exception('User not authenticated');
    }

    await user.updateDisplayName('$firstName $lastName');
    await user.reload();

    final token = await user.getIdToken();
    if (token != null) await _storage.saveToken(token);

    return UserModel(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      email: user.email ?? '',
      bio: bio,
      profileImageUrl: profileImageUrl,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      biometricEnabled: false,
    );
  }

  Stream<UserModel?> get authStateStream => _auth.authStateChanges().asyncMap(
    (u) async => u == null ? null : _toUserModel(u),
  );

  User? get currentFirebaseUser => _auth.currentUser;

  // ---------------- Helpers ----------------
  UserModel _toUserModel(User u) {
    final displayName = u.displayName?.trim() ?? '';
    final email = u.email ?? '';
    String firstName;
    String lastName = '';

    if (displayName.isNotEmpty) {
      final parts = displayName.split(' ');
      firstName = parts.first;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    } else if (email.isNotEmpty) {
      // Fallback to email if displayName is empty
      firstName = email.split('@').first;
    } else {
      firstName = 'User';
    }

    return UserModel(
      uid: u.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      profileImageUrl: u.photoURL,
      createdAt: u.metadata.creationTime ?? DateTime.now(),
      biometricEnabled: false,
    );
  }

  Exception _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('Password is too weak');
      case 'operation-not-allowed':
        return Exception(
          'This sign-in method is disabled for this Firebase project. Enable it in the Firebase console under Authentication → Sign-in method.',
        );
      case 'email-already-in-use':
        return Exception('Email is already registered');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'user-not-found':
        return Exception('User not found');
      case 'wrong-password':
        return Exception('Wrong password');
      case 'user-disabled':
        return Exception('User account is disabled');
      case 'too-many-requests':
        return Exception('Too many login attempts. Try again later');
      case 'network-request-failed':
        return Exception('Network error. Check your connection');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
}
