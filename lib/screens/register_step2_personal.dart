import 'package:flutter/material.dart';
import '../models/registration_data.dart';
import '../utils/auto_save.dart';
import 'register_step3_community.dart';

class RegisterStep2Personal extends StatefulWidget {
  final RegistrationData data;

  const RegisterStep2Personal({super.key, required this.data});

  @override
  State<RegisterStep2Personal> createState() => _RegisterStep2PersonalState();
}

class _RegisterStep2PersonalState extends State<RegisterStep2Personal> {
  String? selectedGender;
  String? selectedMaritalStatus;
  DateTime? selectedDob;

  final heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD1C8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF820815)),
          onPressed: () => Navigator.pop(context), // back to Step 1
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
                      // 🔹 Step text
                      const Text(
                        "· Step 2 of 5 ·",
                        style: TextStyle(
                          color: Color(0xFF820815),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 🔹 Progress Bar
                      LinearProgressIndicator(
                        value: 2 / 5,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFFFB8AB),
                        color: const Color(0xFF820815),
                        borderRadius: BorderRadius.circular(100),
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        "Personal Information",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF820815),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Date of Birth
                      TextField(
                        readOnly: true,
                        decoration: _decoration("Date of Birth"),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                            initialDate: DateTime(2000),
                          );

                          if (picked != null) {
                            setState(() {
                              selectedDob = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Gender
                      DropdownButtonFormField<String>(
                        decoration: _decoration("Gender"),
                        items: const [
                          DropdownMenuItem(value: "Male", child: Text("Male")),
                          DropdownMenuItem(
                            value: "Female",
                            child: Text("Female"),
                          ),
                          DropdownMenuItem(
                            value: "Other",
                            child: Text("Other"),
                          ),
                        ],
                        onChanged: (value) {
                          selectedGender = value;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Height
                      TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration: _decoration("Height (cm)"),
                      ),
                      const SizedBox(height: 16),

                      // Marital Status
                      DropdownButtonFormField<String>(
                        decoration: _decoration("Marital Status"),
                        items: const [
                          DropdownMenuItem(
                            value: "Unmarried",
                            child: Text("Unmarried"),
                          ),
                          DropdownMenuItem(
                            value: "Divorced/Widowed",
                            child: Text("Divorced/Widowed"),
                          ),
                        ],
                        onChanged: (value) {
                          selectedMaritalStatus = value;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Next Button
                      ElevatedButton(
                        style: _buttonStyle(),
                        onPressed: () async {
                          widget.data.gender = selectedGender;
                          widget.data.dob = selectedDob;
                          widget.data.height = heightController.text;
                          widget.data.maritalStatus = selectedMaritalStatus;

                          await autoSaveStep(widget.data, 2);

                          if (!context.mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisterStep3Community(data: widget.data),
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
