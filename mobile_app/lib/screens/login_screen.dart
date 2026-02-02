import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_step1_account.dart';
import 'forgot_password_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _useOtp = false;
  bool _otpSent = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  final _authService = AuthService.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    bool success = false;

    if (_useOtp) {
      if (!_otpSent) {
        // Request OTP
        success = await _authService.requestOtp(_emailController.text.trim());
        if (success) {
          setState(() => _otpSent = true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("OTP Sent! (Check console for demo code)"),
              ),
            );
          }
        } else {
          _showError("Failed to send OTP. Check phone number.");
        }
      } else {
        // Verify OTP Login
        success = await _authService.loginWithOtp(
          _emailController.text.trim(),
          _otpController.text.trim(),
        );
        if (!success) _showError("Invalid OTP");
      }
    } else {
      // Password Login
      success = await _authService.loginWithPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!success) _showError("Invalid Phone or Password");
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success && (_useOtp ? _otpSent : true)) {
        // If OTP flow, we only navigate if verification succeeded (which sets currentUser)
        // Actually loginWithOtp returns true only on success.
        // For Request OTP, success is true but we don't navigate yet.
        if (_useOtp && !_otpSent) {
          // Case: Request OTP success (handled above by setting _otpSent)
        } else {
          // Login Success
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF820815),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Toggle Tab
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            children: [
                              _buildTab("Password", !_useOtp),
                              _buildTab("OTP", _useOtp),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildTextField(
                          label: "Phone Number",
                          controller: _emailController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length < 10) {
                              return "Enter a valid 10-digit phone number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        if (_useOtp) ...[
                          if (_otpSent)
                            _buildTextField(
                              label: "Enter OTP",
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value!.length < 4 ? "Enter valid OTP" : null,
                            ),
                          if (!_otpSent)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                "We will send an OTP to your phone.",
                                style: TextStyle(color: Color(0xFF820815)),
                              ),
                            ),
                        ] else
                          _buildPasswordField(),

                        if (!_useOtp)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Forgot password?",
                                style: TextStyle(
                                  color: Color(0xFF6E040F),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF820815),
                              foregroundColor: const Color(0xFFFFD1C8),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFFFD1C8),
                                    ),
                                  )
                                : Text(
                                    _useOtp
                                        ? (_otpSent
                                              ? "Verify & Login"
                                              : "Get OTP")
                                        : "Login",
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF820815),
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(text: "Don’t have an account? "),
                              TextSpan(
                                text: "Register",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6E040F),
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterStep1Account(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _useOtp = title == "OTP";
            _otpSent = false;
            _otpController.clear();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF820815) : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFFFFD1C8)
                  : const Color(0xFF820815),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: _inputDecoration("Password").copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF820815),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF820815)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF820815)),
        borderRadius: BorderRadius.circular(100),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF820815), width: 2),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
