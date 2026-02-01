import 'package:flutter/material.dart';
import '../models/registration_data.dart';
import 'package:shared/shared.dart';
import 'register_step4_career.dart';

class RegisterStep3Community extends StatefulWidget {
  final RegistrationData data;

  const RegisterStep3Community({super.key, required this.data});

  @override
  State<RegisterStep3Community> createState() => _RegisterStep3CommunityState();
}

class _RegisterStep3CommunityState extends State<RegisterStep3Community> {
  final _formKey = GlobalKey<FormState>();
  final fatherController = TextEditingController();
  final motherController = TextEditingController();
  final guardianNameController = TextEditingController();
  final guardianRelationController = TextEditingController();
  final casteController = TextEditingController();
  final subCasteController = TextEditingController();
  final motherTongueController = TextEditingController();
  final languagesController = TextEditingController();
  final homeTownController = TextEditingController();
  final siblingsCountController = TextEditingController();

  String guardianType = "Father"; // default
  bool? hasSiblings = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C8),
      appBar: AppBar(
        // Background color handled by Theme
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "· Step 3 of 5 ·",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        LinearProgressIndicator(
                          value: 3 / 5,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFFFB8AB),
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          "Family & Community Details",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),

                        _textField(
                          "Father’s Name",
                          fatherController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter father's name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _textField(
                          "Mother’s Name",
                          motherController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter mother's name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Legal Guardian Selector
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Legal Guardian",
                          ),
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
                          _textField(
                            "Guardian Name",
                            guardianNameController,
                            validator: (value) {
                              if (guardianType == "Other" &&
                                  (value == null || value.isEmpty)) {
                                return "Please enter guardian name";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _textField(
                            "Relationship",
                            guardianRelationController,
                            validator: (value) {
                              if (guardianType == "Other" &&
                                  (value == null || value.isEmpty)) {
                                return "Please enter relationship";
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Siblings Question
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Do you have siblings?",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            RadioGroup<bool>(
                              groupValue: hasSiblings,
                              onChanged: (val) {
                                setState(() {
                                  hasSiblings = val;
                                  if (val == false) {
                                    siblingsCountController.clear();
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  const Radio<bool>(value: true),
                                  const Text("Yes"),
                                  const SizedBox(width: 20),
                                  const Radio<bool>(value: false),
                                  const Text("No"),
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (hasSiblings == true) ...[
                          const SizedBox(height: 8),
                          _textField(
                            "Number of Siblings",
                            siblingsCountController,
                            keyboard: TextInputType.number,
                            validator: (value) {
                              if (hasSiblings == true &&
                                  (value == null || value.isEmpty)) {
                                return "Please enter number of siblings";
                              }
                              if (int.tryParse(value ?? '') == null) {
                                return "Enter a valid number";
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 16),

                        _textField(
                          "Caste",
                          casteController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter caste";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _textField(
                          "Sub‑caste",
                          subCasteController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter sub-caste";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _textField(
                          "Mother Tongue",
                          motherTongueController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter mother tongue";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _textField(
                          "Languages (comma separated)",
                          languagesController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter languages known";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _textField(
                          "Home Town",
                          homeTownController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter home town";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        ElevatedButton(
                          style: AppStyles.primaryButtonStyle,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              widget.data.fatherName = fatherController.text;
                              widget.data.motherName = motherController.text;
                              widget.data.caste = casteController.text;
                              widget.data.subCaste = subCasteController.text;
                              widget.data.motherTongue =
                                  motherTongueController.text;
                              widget.data.languages = languagesController.text;
                              widget.data.hometown = homeTownController.text;

                              if (hasSiblings == true) {
                                widget.data.siblings =
                                    int.tryParse(
                                      siblingsCountController.text,
                                    ) ??
                                    0;
                              } else {
                                widget.data.siblings = 0;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RegisterStep4Career(data: widget.data),
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
      decoration: InputDecoration(labelText: label),
      validator: validator,
    );
  }
}
