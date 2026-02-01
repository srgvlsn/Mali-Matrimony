import 'package:flutter/material.dart';
import '../models/registration_data.dart';
import '../utils/auto_save.dart';
import 'package:shared/shared.dart';
import 'register_step5_profile.dart';
import '../utils/registration_draft.dart';

class RegisterStep4Career extends StatefulWidget {
  final RegistrationData data;

  const RegisterStep4Career({super.key, required this.data});

  @override
  State<RegisterStep4Career> createState() => _RegisterStep4CareerState();
}

class _RegisterStep4CareerState extends State<RegisterStep4Career> {
  final _formKey = GlobalKey<FormState>();
  final educationController = TextEditingController();
  final professionController = TextEditingController();
  final companyController = TextEditingController();
  final incomeController = TextEditingController();
  final cityController = TextEditingController();

  String workMode = "Office";

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
          onPressed: () => Navigator.pop(context), // back to Step 3
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
                        // Step label
                        Text(
                          "· Step 4 of 5 ·",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Progress bar
                        LinearProgressIndicator(
                          value: 4 / 5,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFFFB8AB),
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          "Career & Work Details",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),

                        _textField(
                          "Education",
                          educationController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your education";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _textField(
                          "Profession",
                          professionController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your profession";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _textField(
                          "Company Name",
                          companyController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter company name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _textField(
                          "Annual Income",
                          incomeController,
                          keyboard: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter annual income";
                            }
                            if (double.tryParse(value) == null) {
                              return "Enter a valid amount";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _textField(
                          "Working City",
                          cityController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter working city";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Work Mode
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: "Work Mode"),
                          initialValue: workMode,
                          items: const [
                            DropdownMenuItem(
                              value: "Office",
                              child: Text("Office"),
                            ),
                            DropdownMenuItem(
                              value: "Work From Home",
                              child: Text("Work From Home"),
                            ),
                            DropdownMenuItem(
                              value: "Hybrid",
                              child: Text("Hybrid"),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select work mode";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              workMode = value!;
                            });
                          },
                        ),

                        const SizedBox(height: 32),

                        ElevatedButton(
                          style: AppStyles.primaryButtonStyle,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              widget.data.education = educationController.text;
                              widget.data.profession =
                                  professionController.text;
                              widget.data.company = companyController.text;
                              widget.data.annualIncome = incomeController.text;
                              widget.data.workingCity = cityController.text;
                              widget.data.workMode = workMode;

                              await autoSaveStep(widget.data, 4);

                              if (!context.mounted) return;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RegisterStep5Profile(data: widget.data),
                                ),
                              );
                            }
                          },
                          child: const Text("Next"),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () async {
                            // Save current state regardless of validation for drafts
                            widget.data.education = educationController.text;
                            widget.data.profession = professionController.text;
                            widget.data.company = companyController.text;
                            widget.data.annualIncome = incomeController.text;
                            widget.data.workingCity = cityController.text;
                            widget.data.workMode = workMode;

                            widget.data.lastCompletedStep = 3;
                            await RegistrationDraft.save(widget.data);

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Progress saved. You can resume later.",
                                ),
                              ),
                            );

                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          },
                          child: const Text(
                            "Save & Resume Later",
                            style: TextStyle(
                              color: Color(0xFF6E040F),
                              fontWeight: FontWeight.w500,
                            ),
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
