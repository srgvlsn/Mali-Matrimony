import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool otpSent = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final TextEditingController contactController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD1C8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF820815)),
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
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF820815),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email / Phone
                      _buildTextField(
                        controller: contactController,
                        label: "Email or Phone Number",
                      ),
                      const SizedBox(height: 16),

                      // Get OTP button
                      if (!otpSent)
                        ElevatedButton(
                          style: _buttonStyle(),
                          onPressed: () {
                            if (contactController.text.isNotEmpty) {
                              setState(() {
                                otpSent = true;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("OTP sent successfully"),
                                  backgroundColor: Color(0xFF820815),
                                ),
                              );
                            }
                          },
                          child: const Text("Get OTP"),
                        ),

                      // OTP + Password section
                      if (otpSent) ...[
                        _buildTextField(
                          controller: otpController,
                          label: "Enter OTP",
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),

                        _buildPasswordField(
                          label: "New Password",
                          controller: passwordController,
                          obscure: obscurePassword,
                          toggle: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildPasswordField(
                          label: "Confirm Password",
                          controller: confirmPasswordController,
                          obscure: obscureConfirmPassword,
                          toggle: () {
                            setState(() {
                              obscureConfirmPassword =
                                  !obscureConfirmPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          style: _buttonStyle(),
                          onPressed: () {
                            if (passwordController.text ==
                                confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Password reset successful"),
                                  backgroundColor: Color(0xFF820815),
                                ),
                              );

                              Navigator.pop(context); // Back to login
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Passwords do not match"),
                                  backgroundColor: Color(0xFF820815),
                                ),
                              );
                            }
                          },
                          child: const Text("Reset Password"),
                        ),
                      ],
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

  // TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label),
    );
  }

  // Password Field with toggle
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: _inputDecoration(label).copyWith(
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

  // Shared decoration
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF820815)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF820815)),
        borderRadius: BorderRadius.circular(100),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFF820815),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF820815),
      foregroundColor: const Color(0xFFFFD1C8),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
