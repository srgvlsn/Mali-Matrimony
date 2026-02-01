import 'package:flutter/material.dart';
import '../models/registration_data.dart';
import '../utils/auto_save.dart';
import 'package:shared/shared.dart';
import 'register_step2_personal.dart';

class RegisterStep1Account extends StatefulWidget {
  const RegisterStep1Account({super.key});

  @override
  State<RegisterStep1Account> createState() => _RegisterStep1AccountState();
}

class _RegisterStep1AccountState extends State<RegisterStep1Account> {
  final RegistrationData data = RegistrationData();

  final _formKey = GlobalKey<FormState>();

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
      // Background color is handled by Theme (scaffoldBackgroundColor)
      appBar: AppBar(
        // Background color handled by Theme
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "· Step 1 of 5 ·",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        LinearProgressIndicator(
                          value: 1 / 5, // Step 1
                          minHeight: 6,
                          backgroundColor: const Color(
                            0xFFFFB8AB,
                          ), // Keep specific color if not in theme
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(100),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),

                        _textField(
                          "Full Name",
                          _fullName,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your full name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _textField(
                          "Phone Number",
                          _phone,
                          keyboard: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your phone number";
                            }
                            if (value.length < 10) {
                              return "Enter a valid 10-digit phone number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _textField(
                          "Email (optional)",
                          _email,
                          keyboard: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return "Enter a valid email address";
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _passwordField(
                          "Password",
                          _password,
                          obscurePassword,
                          () => setState(() {
                            obscurePassword = !obscurePassword;
                          }),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a password";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _passwordField(
                          "Confirm Password",
                          _confirmPassword,
                          obscureConfirmPassword,
                          () => setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          }),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please confirm your password";
                            }
                            if (value != _password.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          // Use AppStyles or default theme. AppStyles matches the previous specific padding.
                          style: AppStyles.primaryButtonStyle,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              data.fullName = _fullName.text;
                              data.phone = _phone.text;
                              data.email = _email.text;
                              data.password = _password.text;

                              await autoSaveStep(data, 1);

                              if (!context.mounted) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RegisterStep2Personal(data: data),
                                ),
                              );
                            }
                          },
                          child: const Text("Next"),
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

  Widget _textField(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      // Uses global InputDecorationTheme from main.dart
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }

  Widget _passwordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      // Merge suffixIcon with global theme decoration
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }
}

