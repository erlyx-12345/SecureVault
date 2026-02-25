import 'package:flutter/foundation.dart';

/// Minimal `ProfileViewModel` placeholder used by the app.
class ProfileViewModel extends ChangeNotifier {
	String _name = 'User';

	String get name => _name;

	void updateName(String newName) {
		_name = newName;
		notifyListeners();
	}
}
