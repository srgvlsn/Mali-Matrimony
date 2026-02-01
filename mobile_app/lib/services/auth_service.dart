import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import '../models/registration_data.dart';

class AuthService extends ChangeNotifier {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  UserProfile? get currentUser => MockBackend.instance.currentUser;
  bool get isLoggedIn => MockBackend.instance.currentUserId != null;

  void refresh() {
    notifyListeners();
  }

  /// Simulates a login attempt using the Mock Backend
  Future<bool> login(String emailOrPhone, String password) async {
    final response = await MockBackend.instance.login(emailOrPhone, password);
    if (response.success) {
      notifyListeners();
    }
    return response.success;
  }

  /// Simulates a registration using the Mock Backend
  Future<bool> register(RegistrationData data) async {
    final user = data.toUserProfile();
    final response = await MockBackend.instance.registerUser(user);
    if (response.success) {
      notifyListeners();
    }
    return response.success;
  }

  Future<void> logout() async {
    await MockBackend.instance.logout();
    notifyListeners();
  }
}
