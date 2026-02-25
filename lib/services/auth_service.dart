import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

/// Mock Firebase-like Authentication Service
/// In production, replace with actual Firebase authentication
class AuthService {
  final StorageService _storageService = StorageService();

  // Mock user database (in production, this would be Firebase)
  static final Map<String, Map<String, dynamic>> _mockUserDatabase = {};

  /// Register a new user with email and password
  Future<UserModel> registerWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      // Check if user already exists
      if (_mockUserDatabase.containsKey(email.toLowerCase())) {
        throw Exception('Email is already registered');
      }

      // Create new user
      final uid = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final user = UserModel(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        createdAt: DateTime.now(),
        biometricEnabled: false,
      );

      // Store user data in mock database
      _mockUserDatabase[email.toLowerCase()] = {
        'uid': uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'passwordHash': _hashPassword(password),
        'createdAt': DateTime.now().toIso8601String(),
        'biometricEnabled': false,
      };

      // Generate mock token
      final token = _generateMockToken(uid, email);
      await _storageService.saveToken(token);

      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Login with email and password
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userData = _mockUserDatabase[email.toLowerCase()];

      if (userData == null) {
        throw Exception('User not found');
      }

      // Verify password
      if (_verifyPassword(password, userData['passwordHash'])) {
        final token = _generateMockToken(userData['uid'], email);
        await _storageService.saveToken(token);

        return UserModel(
          uid: userData['uid'],
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          email: userData['email'],
          createdAt: DateTime.parse(userData['createdAt']),
          biometricEnabled: userData['biometricEnabled'] ?? false,
        );
      } else {
        throw Exception('Invalid password');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Google Sign-In (currently using mock implementation)
  /// In production, integrate with Firebase Google Sign-In
  Future<UserModel> signInWithGoogle() async {
    try {
      // Mock Google Sign-In
      // In production: Use google_sign_in package
      final mockGoogleUser = {
        'uid': 'google_${DateTime.now().millisecondsSinceEpoch}',
        'firstName': 'Google',
        'lastName': 'User',
        'email': 'user@gmail.com',
        'profileImageUrl':
            'https://lh3.googleusercontent.com/a/default-user=s96-c',
      };

      final user = UserModel(
        uid: mockGoogleUser['uid']!,
        firstName: mockGoogleUser['firstName']!,
        lastName: mockGoogleUser['lastName']!,
        email: mockGoogleUser['email']!,
        profileImageUrl: mockGoogleUser['profileImageUrl'],
        createdAt: DateTime.now(),
        biometricEnabled: false,
      );

      // Store user if new
      if (!_mockUserDatabase.containsKey(
        mockGoogleUser['email']!.toLowerCase(),
      )) {
        _mockUserDatabase[mockGoogleUser['email']!.toLowerCase()] = {
          ...mockGoogleUser,
          'createdAt': DateTime.now().toIso8601String(),
        };
      }

      final token = _generateMockToken(user.uid, user.email);
      await _storageService.saveToken(token);

      return user;
    } catch (e) {
      throw Exception('Google Sign-In failed: ${e.toString()}');
    }
  }

  /// Facebook Sign-In (bonus feature)
  /// In production, integrate with facebook_flutter package
  Future<UserModel> signInWithFacebook() async {
    try {
      // Mock Facebook Sign-In
      final mockFacebookUser = {
        'uid': 'facebook_${DateTime.now().millisecondsSinceEpoch}',
        'firstName': 'Facebook',
        'lastName': 'User',
        'email': 'user@facebook.com',
        'profileImageUrl':
            'https://platform-lookaside.fbsbx.com/platform/profilepic/default.png',
      };

      final user = UserModel(
        uid: mockFacebookUser['uid']!,
        firstName: mockFacebookUser['firstName']!,
        lastName: mockFacebookUser['lastName']!,
        email: mockFacebookUser['email']!,
        profileImageUrl: mockFacebookUser['profileImageUrl'],
        createdAt: DateTime.now(),
        biometricEnabled: false,
      );

      if (!_mockUserDatabase.containsKey(
        mockFacebookUser['email']!.toLowerCase(),
      )) {
        _mockUserDatabase[mockFacebookUser['email']!.toLowerCase()] = {
          ...mockFacebookUser,
          'createdAt': DateTime.now().toIso8601String(),
        };
      }

      final token = _generateMockToken(user.uid, user.email);
      await _storageService.saveToken(token);

      return user;
    } catch (e) {
      throw Exception('Facebook Sign-In failed: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<UserModel> updateUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      // Find and update user in mock database
      String? emailKey;
      for (var entry in _mockUserDatabase.entries) {
        if (entry.value['uid'] == uid) {
          emailKey = entry.key;
          break;
        }
      }

      if (emailKey == null) {
        throw Exception('User not found');
      }

      _mockUserDatabase[emailKey]!.addAll({
        'firstName': firstName,
        'lastName': lastName,
        'bio': bio,
        'profileImageUrl': profileImageUrl,
      });

      return UserModel(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: emailKey,
        bio: bio,
        profileImageUrl: profileImageUrl,
        createdAt: DateTime.parse(_mockUserDatabase[emailKey]!['createdAt']),
        biometricEnabled:
            _mockUserDatabase[emailKey]!['biometricEnabled'] ?? false,
      );
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  /// Get current user from token
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return null;

      // Decode token to get user info (mock implementation)
      final decoded = _decodeMockToken(token);
      if (decoded == null) return null;

      final userData = _mockUserDatabase[decoded['email']];
      if (userData == null) return null;

      return UserModel(
        uid: userData['uid'],
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        email: userData['email'],
        profileImageUrl: userData['profileImageUrl'],
        bio: userData['bio'],
        createdAt: DateTime.parse(userData['createdAt']),
        biometricEnabled: userData['biometricEnabled'] ?? false,
      );
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _storageService.clearToken();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // ========== Helper Methods ==========

  /// Mock password hashing (in production, use bcrypt or argon2)
  static String _hashPassword(String password) {
    // Simple hash for mock purposes
    return 'hashed_$password';
  }

  /// Mock password verification (in production, use proper crypto)
  static bool _verifyPassword(String password, String hash) {
    return hash == 'hashed_$password';
  }

  /// Generate mock JWT token
  static String _generateMockToken(String uid, String email) {
    final payload = {
      'uid': uid,
      'email': email,
      'iat': DateTime.now().millisecondsSinceEpoch,
    };
    // Simple base64 encoding for mock (not secure for production)
    return base64Encode(utf8.encode(jsonEncode(payload)));
  }

  /// Decode mock token
  static Map<String, dynamic>? _decodeMockToken(String token) {
    try {
      final decoded = utf8.decode(base64Decode(token));
      return jsonDecode(decoded);
    } catch (e) {
      return null;
    }
  }
}
