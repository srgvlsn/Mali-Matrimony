import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';
import '../models/registration_data.dart';

class AuthService extends ChangeNotifier {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  UserProfile? get currentUser => BackendService.instance.currentUser;
  bool get isLoggedIn => currentUser != null;
  bool get isPremiumUser => currentUser?.isPremium ?? false;

  Future<void> refreshProfile() async {
    await BackendService.instance.refreshCurrentUser();
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  /// Login using Password - Returns null on success, error message on failure
  Future<String?> loginWithPassword(String phone, String password) async {
    final response = await BackendService.instance.login(
      phone,
      password: password,
    );
    if (response.success) {
      notifyListeners();
      return null;
    }
    return response.message;
  }

  /// Request OTP
  Future<ApiResponse<bool>> requestOtp(String phone) async {
    return await BackendService.instance.requestOtp(phone);
  }

  /// Login using OTP
  Future<ApiResponse<UserProfile>> loginWithOtp(
    String phone,
    String otp,
  ) async {
    final response = await BackendService.instance.verifyOtp(phone, otp);
    if (response.success) {
      notifyListeners();
    }
    return response;
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
