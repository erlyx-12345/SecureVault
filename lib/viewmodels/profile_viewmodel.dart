import 'package:flutter/foundation.dart';

/// Minimal `ProfileViewModel` used by `ProfileView`.
class ProfileViewModel extends ChangeNotifier {
  String _name = 'User';

  String get name => _name;

  set name(String value) {
    if (value == _name) return;
    _name = value;
    notifyListeners();
  }
}
