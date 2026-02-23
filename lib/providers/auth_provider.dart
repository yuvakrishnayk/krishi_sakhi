import 'package:flutter/foundation.dart';

import '../auth/auth_repository.dart';
import '../auth/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  bool _loading = false;
  String? _error;
  User? _user;

  AuthProvider({required this.repository});

  bool get loading => _loading;
  String? get error => _error;
  User? get user => _user;

  Future<bool> register({
    required String name,
    required String mobile,
    required String pin,
    required String confirmPin,
    String? imagePath,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final u = await repository.register(
        name: name,
        mobile: mobile,
        pin: pin,
        confirmPin: confirmPin,
        imagePath: imagePath,
      );
      _user = u;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String mobile, required String pin}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final u = await repository.login(mobile: mobile, pin: pin);
      _user = u;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    _user = null;
    notifyListeners();
  }
}
