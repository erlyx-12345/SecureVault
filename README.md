# SecureVault - Secure Authentication Application

A Flutter application implementing strict MVVM architecture with secure authentication, biometric login, and secure token storage.

---

## 👥 Team Members & Roles

| Member | Role | Responsibilities |
|--------|------|------------------|
| M1 | Lead Architect & Navigation | Project setup, folder structure, named routes, MultiProvider configuration |
| M2 | Core Auth Developer | AuthViewModel, custom registration, login logic, state management |
| M3 | Security Engineer | Secure storage (flutter_secure_storage), biometric authentication (local_auth), password validators |
| M4 | UI/UX Designer | LoginView, RegisterView, ProfileView, reusable widgets, Consumer logic |
| M5 | Integration Specialist | Google Sign-In, Facebook Login (bonus), profile QA testing |

---

## ✨ Features

### Core Features
- ✅ Secure User Registration (Email/Password)
- ✅ User Login with validation
- ✅ View & Edit User Profile
- ✅ Biometric Authentication (Fingerprint/FaceID)
- ✅ Secure Token Storage
- ✅ Google Sign-In Integration
- ✅ Multi-provider state management (Provider)

### Bonus Features (Optional)
- 🎁 Facebook Login (+5 pts)
- 🎁 Dark Mode Toggle with persistence (+5 pts)

---

## 🏗️ Project Structure (Strict MVVM)

```
lib/
├── main.dart                      # Entry point with routes & MultiProvider
├── models/
│   └── user_model.dart           # User data structure
├── services/
│   ├── auth_service.dart         # Firebase & authentication methods
│   ├── storage_service.dart      # Secure storage implementation
│   └── biometric_service.dart    # Fingerprint/FaceID logic
├── viewmodels/
│   ├── auth_viewmodel.dart       # Authentication logic & state
│   └── profile_viewmodel.dart    # Profile editing logic & state
├── views/
│   ├── login_view.dart           # Login screen
│   ├── register_view.dart        # Registration screen
│   ├── profile_view.dart         # Profile view & edit screen
│   └── widgets/                  # Reusable UI components
└── utils/
    ├── constants.dart            # Colors, strings, API keys
    └── validators.dart           # Email/password validation regex
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.7 or higher)
- Dart SDK
- Git

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd securevault

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🔒 Security Features

### Password Requirements
- Minimum 8 characters
- At least 1 uppercase letter
- At least 1 special character (!@#$%^&*)

### Storage
- Tokens stored securely using `flutter_secure_storage`
- Passwords NOT stored locally
- Biometric data managed by device

---

## 📱 Building APK

```bash
# Build release APK
flutter build apk --release

# APK location: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔑 Dependencies

```yaml
provider: ^6.0.5          # State management
```

---

## 📋 Development Guidelines

### Naming Conventions
- Classes: PascalCase (e.g., `AuthViewModel`)
- Methods/Variables: camelCase (e.g., `handleLogin()`)
- Files: snake_case (e.g., `auth_viewmodel.dart`)

### Code Organization
- **Views**: UI only, no business logic
- **ViewModels**: State management & logic
- **Services**: API/Database interactions
- **Models**: Data structures

---

## 🧪 Testing Checklist

- [ ] Registration with valid/invalid credentials
- [ ] Login functionality
- [ ] Profile view displays user data
- [ ] Edit profile updates immediately (notifyListeners)
- [ ] Biometric toggle works
- [ ] Fingerprint login prompts on app restart
- [ ] Google Sign-In successful
- [ ] Tokens persist after app restart
- [ ] Data cleared on logout

---

## 📝 Submission Requirements

- ✅ Public GitHub Repository
- ✅ README.md with team members & roles
- ⏳ APK file (.apk compiled) - To be added after development

---

## 📄 License

Academic Project - Information Assurance and Security 2
