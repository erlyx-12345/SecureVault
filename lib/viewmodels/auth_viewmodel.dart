import 'package:flutter/foundation.dart';

/// Minimal `AuthViewModel` placeholder used by the app.
class AuthViewModel extends ChangeNotifier {
	bool _signedIn = false;

	bool get signedIn => _signedIn;

	void signIn() {
		_signedIn = true;
		notifyListeners();
	}

	void signOut() {
		_signedIn = false;
		notifyListeners();
	}
}
