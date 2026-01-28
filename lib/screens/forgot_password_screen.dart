import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool otpSent = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  final TextEditingController contactController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    contactController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      isLoading = false;
      otpSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("OTP sent successfully"),
        backgroundColor: Color(0xFF820815),
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password reset successful"),
        backgroundColor: Color(0xFF820815),
      ),
    );

    Navigator.pop(context); // Back to login
  }

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
                  child: Form(
                    key: _formKey,
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
                        _buildTextFormField(
                          controller: contactController,
                          label: "Email or Phone Number",
                          enabled: !otpSent,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter email or phone number";
                            }
                            // Basic validation for email or 10-digit phone
                            final isEmail = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value);
                            final isPhone = RegExp(r'^\d{10}$').hasMatch(value);
                            if (!isEmail && !isPhone) {
                              return "Enter a valid email or 10-digit phone number";
                            }
                            return null;
                          },
                          suffixIcon: otpSent
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Color(0xFF820815),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      otpSent = false;
                                      otpController.clear();
                                      passwordController.clear();
                                      confirmPasswordController.clear();
                                    });
                                  },
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Get OTP button
                        if (!otpSent)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: _buttonStyle(),
                              onPressed: isLoading ? null : _sendOtp,
                              child: isLoading
                                  ? const _LoadingIndicator()
                                  : const Text("Get OTP"),
                            ),
                          ),

                        // OTP + Password section
                        if (otpSent) ...[
                          _buildTextFormField(
                            controller: otpController,
                            label: "Enter OTP",
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter the OTP";
                              }
                              if (value.length < 4) {
                                return "Enter a valid OTP";
                              }
                              return null;
                            },
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a new password";
                              }
                              if (value.length < 6) {
                                return "Password must be at least 6 characters";
                              }
                              return null;
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please confirm your password";
                              }
                              if (value != passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: _buttonStyle(),
                              onPressed: isLoading ? null : _resetPassword,
                              child: isLoading
                                  ? const _LoadingIndicator()
                                  : const Text("Reset Password"),
                            ),
                          ),
                        ],
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

  // TextFormField
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label).copyWith(suffixIcon: suffixIcon),
      validator: validator,
    );
  }

  // Password Field with toggle
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
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
      disabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0x66820815)),
        borderRadius: BorderRadius.circular(100),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF820815)),
        borderRadius: BorderRadius.circular(100),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF820815), width: 2),
        borderRadius: BorderRadius.circular(100),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(100),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF820815),
      foregroundColor: const Color(0xFFFFD1C8),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Color(0xFFFFD1C8),
      ),
    );
  }
}
