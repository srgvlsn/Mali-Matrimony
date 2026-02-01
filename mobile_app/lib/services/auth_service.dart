class AuthService {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  /// Simulates a login attempt
  Future<bool> login(String emailOrPhone, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    return emailOrPhone.isNotEmpty && password.isNotEmpty;
  }

  /// Simulates a registration
  Future<bool> register() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
