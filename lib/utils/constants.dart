import 'package:flutter/material.dart';

/// App color constants (DO NOT CHANGE - UI/UX brand colors)
class AppColors {
  // Primary brand colors
  static const Color neonLime = Color(0xFFE2FF6F); // Bright lime accent
  static const Color darkOlive = Color(0xFF1A1D0E); // Dark olive base
  static const Color charcoal = Color(0xFF121212); // Deep charcoal background
  static const Color darkBackground = Colors.black; // Pure black background

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Colors.redAccent;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textHint = Colors.white30;

  // Border colors
  static const Color borderLight = Colors.white10;
  static const Color borderFocus = neonLime;
  static const Color borderDisabled = Colors.white24;
}

/// App string constants
class AppStrings {
  // App titles
  static const String appName = 'SecureVault';
  static const String appTagline = 'Your Secure Digital Identity';

  // Authentication screens
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Step inside and make yourself at home.';
  static const String signInButton = 'Sign in';
  static const String registerTitle = 'Sign up';
  static const String registerSubtitle = 'Create your secure account';
  static const String registerButton = 'Register';
  static const String forgotPassword = 'Forgot Password?';
  static const String orContinueWith = 'Or continue with';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String loginLink = 'Login';
  static const String signUpLink = 'Sign up';

  // Form fields
  static const String firstNameLabel = 'First Name*';
  static const String firstNameHint = 'Steve';
  static const String lastNameLabel = 'Last Name*';
  static const String lastNameHint = 'Rogers';
  static const String emailLabel = 'Email address*';
  static const String emailHint = 'example@gmail.com';
  static const String passwordLabel = 'Password*';
  static const String passwordHint = '@Sn123hsn#';
  static const String confirmPasswordLabel = 'Confirm Password*';
  static const String confirmPasswordHint = '********';

  // Profile screen
  static const String profileTitle = 'My Profile';
  static const String saveChanges = 'SAVE CHANGES';
  static const String logoutButton = 'LOGOUT ACCOUNT';
  static const String editProfile = 'Edit Profile';
  static const String bioLabel = 'Bio';
  static const String enableBiometric = 'Enable Fingerprint Login';
  static const String biometricToggle = 'Fingerprint Authentication';

  // Messages
  static const String successRegistration = 'Account created successfully!';
  static const String successLogin = 'Login successful!';
  static const String successProfileUpdate = 'Profile Updated Successfully!';
  static const String noChangesDetected = 'No changes detected.';
  static const String passwordMismatch = 'Passwords do not match!';
  static const String required = 'Required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String weakPassword = 'Min 8 chars, 1 uppercase, 1 special char';
  static const String biometricNotAvailable =
      'Biometric authentication not available';
  static const String biometricError = 'Biometric authentication failed';
  static const String googleSignInError =
      'Google Sign-In failed. Please try again.';
  static const String facebookSignInError =
      'Facebook Sign-In failed. Please try again.';

  // Social buttons
  static const String googleButton = 'Google';
  static const String facebookButton = 'Facebook';

  // Secure storage keys
  static const String secureTokenKey = 'auth_token';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String userDataKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
}

/// Password validation regex patterns
class ValidationPatterns {
  // Email validation regex (RFC 5322 simplified)
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  // Password validation:
  // - Minimum 8 characters
  // - At least 1 uppercase letter
  // - At least 1 special character (!@#$&*~)
  static const String passwordPattern = r'^(?=.*[A-Z])(?=.*[!@#\$&*~]).{8,}$';

  // Full name validation (letters, spaces, hyphens)
  static const String namePattern = r'^[a-zA-Z\s\-]{2,50}$';
}
