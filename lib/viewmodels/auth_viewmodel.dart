import 'package:flutter/foundation.dart';

/// Minimal `AuthViewModel` placeholder used by the app.
class AuthViewModel extends ChangeNotifier {
	bool _signedIn = false;
	bool _isLoading = false;

	bool get signedIn => _signedIn;
	bool get isLoading => _isLoading;

	void signIn() {
		_signedIn = true;
		notifyListeners();
	}

	void signOut() {
		_signedIn = false;
		notifyListeners();
	}

	void setLoading(bool value) {
		_isLoading = value;
		notifyListeners();
	}
}
