import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import '../models/registration_data.dart';

class AuthService extends ChangeNotifier {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  UserProfile? get currentUser => BackendService.instance.currentUser;
  bool get isLoggedIn => currentUser != null;

  void refresh() {
    notifyListeners();
  }

  /// Login using Password
  Future<bool> loginWithPassword(String phone, String password) async {
    final response = await BackendService.instance.login(
      phone,
      password: password,
    );
    if (response.success) {
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Request OTP
  Future<bool> requestOtp(String phone) async {
    final response = await BackendService.instance.requestOtp(phone);
    return response.success;
  }

  /// Login using OTP
  Future<bool> loginWithOtp(String phone, String otp) async {
    final response = await BackendService.instance.verifyOtp(phone, otp);
    if (response.success) {
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Registration using PostgreSQL
  Future<ApiResponse<UserProfile>> register(RegistrationData data) async {
    final user = data.toUserProfile();
    final response = await BackendService.instance.registerUser(
      user,
      password: data.password,
    );
    if (response.success) {
      notifyListeners();
    }
    return response;
  }

  Future<void> logout() async {
    BackendService.instance.logout();
    notifyListeners();
  }
}
