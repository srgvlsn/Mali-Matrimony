import 'package:flutter/material.dart';
import '../models/registration_data.dart';
import '../utils/auto_save.dart';
import 'register_step2_personal.dart';

class RegisterStep1Account extends StatefulWidget {
  const RegisterStep1Account({super.key});

  @override
  State<RegisterStep1Account> createState() => _RegisterStep1AccountState();
}

class _RegisterStep1AccountState extends State<RegisterStep1Account> {
  final RegistrationData data = RegistrationData();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD1C8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF820815)),
          onPressed: () {
            Navigator.pop(context); // goes back to Login
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "· Step 1 of 5 ·",
                        style: TextStyle(
                          color: Color(0xFF820815),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      LinearProgressIndicator(
                        value: 1 / 5, // Step 1
                        minHeight: 6,
                        backgroundColor: Color(0xFFFFB8AB),
                        color: Color(0xFF820815),
                        borderRadius: BorderRadius.circular(100),
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF820815),
                        ),
                      ),
                      const SizedBox(height: 32),

                      _textField("Full Name", _fullName),
                      const SizedBox(height: 16),

                      _textField(
                        "Phone Number",
                        _phone,
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      _textField(
                        "Email (optional)",
                        _email,
                        keyboard: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      _passwordField(
                        "Password",
                        _password,
                        obscurePassword,
                        () => setState(() {
                          obscurePassword = !obscurePassword;
                        }),
                      ),
                      const SizedBox(height: 16),

                      _passwordField(
                        "Confirm Password",
                        _confirmPassword,
                        obscureConfirmPassword,
                        () => setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        }),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        style: _buttonStyle(),
                        onPressed: () async {
                          if (_password.text != _confirmPassword.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Passwords do not match"),
                              ),
                            );
                            return;
                          }

                          data.fullName = _fullName.text;
                          data.phone = _phone.text;
                          data.email = _email.text;
                          data.password = _password.text;

                          await autoSaveStep(data, 1);

                          if (!context.mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RegisterStep2Personal(data: data),
                            ),
                          );
                        },

                        child: const Text("Next"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: _decoration(label),
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: _decoration(label).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF820815),
          ),
          onPressed: toggle,
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
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

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF820815),
      foregroundColor: const Color(0xFFFFD1C8),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    );
  }
}
