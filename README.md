# SecureVault Identity System

A Flutter application implementing secure authentication and authorization using MVVM architecture.

## Team Members and Roles

- **Member 1 (Solo Developer)**: Lead Architect & Navigation, Core Auth Developer, Security Engineer, UI/UX Designer, Integration Specialist

## Features

- **MVVM Architecture**: Strict separation of UI, business logic, and data layers
- **Secure Authentication**:
  - Custom registration and login with email/password
  - Google Sign-In integration
  - Facebook Login (Bonus)
- **Biometric Security**: Fingerprint/FaceID authentication using local_auth
- **Secure Storage**: Token storage using flutter_secure_storage
- **Profile Management**: View and edit user profile with real-time updates

## Project Structure

```
lib/
├── main.dart                  # Entry point with providers and routes
├── models/
│   └── user_model.dart        # User data structure
├── views/
│   ├── login_view.dart        # Login screen
│   ├── register_view.dart     # Registration screen
│   ├── profile_view.dart      # Profile view and edit screen
│   └── widgets/
│       └── index.dart         # Reusable UI components
├── viewmodels/
│   ├── auth_viewmodel.dart    # Authentication logic and state
│   └── profile_viewmodel.dart # Profile management logic
├── services/
│   ├── auth_service.dart      # Firebase Auth integration
│   ├── storage_service.dart   # Secure storage implementation
│   └── biometric_service.dart # Biometric authentication
└── utils/
    ├── constants.dart         # App constants and configurations
    └── validators.dart        # Input validation utilities
```

## Setup Instructions

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase:
   - Add your `google-services.json` to `android/app/`
   - Enable Authentication in Firebase Console
   - Add Google and Facebook sign-in methods
4. Run the app with `flutter run`

## Dependencies

- firebase_core: ^3.15.2
- firebase_auth: ^5.7.0
- google_sign_in: ^6.1.5
- flutter_facebook_auth: ^7.1.5
- flutter_secure_storage: ^9.2.2
- local_auth: ^2.3.0
- cloud_firestore: ^5.6.12
- provider: ^6.0.5
- image_picker: ^1.0.7
- cupertino_icons: ^1.0.8

## GitHub Repository

https://github.com/erlyx-12345/SecureVault.git

## APK Build

To build the APK:
```bash
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`
