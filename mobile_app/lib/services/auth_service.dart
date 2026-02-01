import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import '../models/registration_data.dart';

class AuthService extends ChangeNotifier {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  bool _isLoggedIn = false;
  UserProfile? _currentUser;

  UserProfile? get currentUser =>
      _currentUser ?? BackendService.instance.currentUser;
  bool get isLoggedIn => _isLoggedIn || currentUser != null;

  void refresh() {
    notifyListeners();
  }

  /// Login attempt using PostgreSQL
  Future<bool> login(String emailOrPhone, String password) async {
    final response = await BackendService.instance.login(
      emailOrPhone,
      password,
    );
    if (response.success) {
      _isLoggedIn = true;
      _currentUser = response.data;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Registration using PostgreSQL
  Future<bool> register(RegistrationData data) async {
    final user = data.toUserProfile();
    final response = await BackendService.instance.registerUser(user);
    if (response.success) {
      _isLoggedIn = true;
      _currentUser = response.data;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}
