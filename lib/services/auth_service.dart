class AuthService {
  AuthService._internal();

  static final AuthService instance = AuthService._internal();

  /// Simulates a login attempt
  Future<bool> login(String phone, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    return phone.isNotEmpty && password.isNotEmpty;
  }

  /// Simulates a registration
  Future<bool> register() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
