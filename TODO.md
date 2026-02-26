# TODO: Fix Google SSO Login Issue

## Tasks
- [x] Add Google Android client ID to AppStrings in constants.dart
- [x] Update auth_service.dart to initialize GoogleSignIn with clientId
- [x] Add checks in signInWithGoogle for accessToken and idToken
- [x] Improve _toUserModel to handle null/empty displayName
- [x] Modify ProfileView to update controllers when user data is available (controllers update when user data is loaded)
- [ ] Test Google sign-in
- [ ] Verify profile displays user data
