import 'package:flutter/material.dart';
import '../models/registration_data.dart';
import 'register_step4_career.dart';

class RegisterStep3Community extends StatefulWidget {
  final RegistrationData data;

  const RegisterStep3Community({super.key, required this.data});

  @override
  State<RegisterStep3Community> createState() => _RegisterStep3CommunityState();
}

class _RegisterStep3CommunityState extends State<RegisterStep3Community> {
  final fatherController = TextEditingController();
  final motherController = TextEditingController();
  final guardianNameController = TextEditingController();
  final guardianRelationController = TextEditingController();
  final casteController = TextEditingController();
  final subCasteController = TextEditingController();
  final motherTongueController = TextEditingController();
  final languagesController = TextEditingController();

  String guardianType = "Father"; // default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD1C8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF820815)),
          onPressed: () => Navigator.pop(context), // back to Step 2
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
                        "· Step 3 of 5 ·",
                        style: TextStyle(
                          color: Color(0xFF820815),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      LinearProgressIndicator(
                        value: 3 / 5,
                        minHeight: 6,
                        backgroundColor: Color(0xFFFFB8AB),
                        color: Color(0xFF820815),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        "Family & Community Details",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF820815),
                        ),
                      ),
                      const SizedBox(height: 32),

                      _textField("Father’s Name", fatherController),
                      const SizedBox(height: 16),

                      _textField("Mother’s Name", motherController),
                      const SizedBox(height: 16),

                      // Legal Guardian Selector
                      DropdownButtonFormField<String>(
                        decoration: _decoration("Legal Guardian"),
                        initialValue: guardianType,
                        items: const [
                          DropdownMenuItem(
                            value: "Father",
                            child: Text("Father"),
                          ),
                          DropdownMenuItem(
                            value: "Mother",
                            child: Text("Mother"),
                          ),
                          DropdownMenuItem(
                            value: "Other",
                            child: Text("Other"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            guardianType = value!;
                          });
                        },
                      ),

                      if (guardianType == "Other") ...[
                        const SizedBox(height: 16),
                        _textField("Guardian Name", guardianNameController),
                        const SizedBox(height: 16),
                        _textField("Relationship", guardianRelationController),
                      ],

                      const SizedBox(height: 16),

                      _textField("Caste", casteController),
                      const SizedBox(height: 16),

                      _textField("Sub‑caste", subCasteController),
                      const SizedBox(height: 16),

                      _textField("Mother Tongue", motherTongueController),
                      const SizedBox(height: 16),

                      _textField(
                        "Languages (comma separated)",
                        languagesController,
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        style: _buttonStyle(),
                        onPressed: () {
                          widget.data.caste = casteController.text;
                          widget.data.subCaste = subCasteController.text;
                          widget.data.motherTongue =
                              motherTongueController.text;

                          // Family details can be extended in model later
                          // widget.data.guardianType = guardianType;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisterStep4Career(data: widget.data),
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

  Widget _textField(String label, TextEditingController controller) {
    return TextField(controller: controller, decoration: _decoration(label));
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
