import 'package:flutter/material.dart';
import '../utils/app_styles.dart';
import 'admin_shell.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Side - Mural / Brand
          Expanded(
            flex: 6,
            child: Container(
              color: AppStyles.primary,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.1,
                    child: Image.network(
                      "https://images.unsplash.com/photo-1518156677180-95a2893f3e9f?q=80&w=2787&auto=format&fit=crop",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.admin_panel_settings,
                          size: 100,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "MALI MATRIMONY",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                        Text(
                          "ADMINISTRATION PORTAL v1.0",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right Side - Login Form
          Expanded(
            flex: 4,
            child: Container(
              color: AppStyles.background,
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppStyles.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please enter your credentials to continue.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 48),
                  _buildLabel("Admin ID"),
                  TextField(
                    controller: _idController,
                    decoration: _buildInputDecoration("e.g. admin_01"),
                  ),
                  const SizedBox(height: 24),
                  _buildLabel("Password"),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    decoration: _buildInputDecoration("••••••••"),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: AppStyles.primaryButtonStyle.copyWith(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 24),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "LOGIN TO DASHBOARD",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: AppStyles.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppStyles.primary,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    );
  }
}
