import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../services/admin_service.dart';

class UserEditDialog extends StatefulWidget {
  final UserProfile user;

  const UserEditDialog({super.key, required this.user});

  static Future<bool?> show(BuildContext context, UserProfile user) {
    return showDialog<bool>(
      context: context,
      builder: (context) => UserEditDialog(user: user),
    );
  }

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _educationController;
  late TextEditingController _occupationController;
  late TextEditingController _companyController;
  late TextEditingController _incomeController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  late TextEditingController _partnerPreferencesController;

  late TextEditingController _fatherNameController;
  late TextEditingController _motherNameController;
  late TextEditingController _siblingsController;

  late TextEditingController _casteController;
  late TextEditingController _subCasteController;
  late TextEditingController _motherTongueController;
  late TextEditingController _languagesController;

  late TextEditingController _hometownController;
  late TextEditingController _workModeController;

  late Gender _selectedGender;
  late MaritalStatus _selectedMaritalStatus;
  late bool _isVerified;
  late bool _isPremium;
  late bool _showPhone;
  late bool _showEmail;
  late TextEditingController _premiumExpiryDateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _ageController = TextEditingController(text: widget.user.age.toString());
    _heightController = TextEditingController(
      text: widget.user.height.toString(),
    );
    _educationController = TextEditingController(text: widget.user.education);
    _occupationController = TextEditingController(text: widget.user.occupation);
    _companyController = TextEditingController(text: widget.user.company);
    _incomeController = TextEditingController(text: widget.user.income);
    _locationController = TextEditingController(text: widget.user.location);
    _bioController = TextEditingController(text: widget.user.bio);
    _partnerPreferencesController = TextEditingController(
      text: widget.user.partnerPreferences,
    );

    _fatherNameController = TextEditingController(text: widget.user.fatherName);
    _motherNameController = TextEditingController(text: widget.user.motherName);
    _siblingsController = TextEditingController(
      text: widget.user.siblings.toString(),
    );

    _casteController = TextEditingController(text: widget.user.caste);
    _subCasteController = TextEditingController(text: widget.user.subCaste);
    _motherTongueController = TextEditingController(
      text: widget.user.motherTongue,
    );
    _languagesController = TextEditingController(
      text: widget.user.languages.join(', '),
    );

    _hometownController = TextEditingController(
      text: widget.user.hometown ?? '',
    );
    _workModeController = TextEditingController(
      text: widget.user.workMode ?? '',
    );

    _selectedGender = widget.user.gender;
    _selectedMaritalStatus = widget.user.maritalStatus;
    _isVerified = widget.user.isVerified;
    _isPremium = widget.user.isPremium;
    _showPhone = widget.user.showPhone;
    _showEmail = widget.user.showEmail;
    _premiumExpiryDateController = TextEditingController(
      text:
          widget.user.premiumExpiryDate?.toIso8601String().split('T').first ??
          '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _educationController.dispose();
    _occupationController.dispose();
    _companyController.dispose();
    _incomeController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _partnerPreferencesController.dispose();

    _fatherNameController.dispose();
    _motherNameController.dispose();
    _siblingsController.dispose();
    _casteController.dispose();
    _subCasteController.dispose();
    _motherTongueController.dispose();
    _languagesController.dispose();

    _hometownController.dispose();
    _workModeController.dispose();

    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final updatedUser = widget.user.copyWith(
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          age: int.tryParse(_ageController.text) ?? 25,
          height: double.tryParse(_heightController.text) ?? 5.5,
          gender: _selectedGender,
          maritalStatus: _selectedMaritalStatus,
          caste: _casteController.text,
          subCaste: _subCasteController.text,
          motherTongue: _motherTongueController.text,
          education: _educationController.text,
          occupation: _occupationController.text,
          company: _companyController.text,
          income: _incomeController.text,
          location: _locationController.text,
          fatherName: _fatherNameController.text,
          motherName: _motherNameController.text,
          siblings: int.tryParse(_siblingsController.text) ?? 0,
          bio: _bioController.text,
          partnerPreferences: _partnerPreferencesController.text,
          isVerified: _isVerified,
          isPremium: _isPremium,
          showPhone: _showPhone,
          showEmail: _showEmail,
          premiumExpiryDate: _premiumExpiryDateController.text.isNotEmpty
              ? DateTime.tryParse(_premiumExpiryDateController.text)
              : null,
          languages: _languagesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          hometown: _hometownController.text.isEmpty
              ? null
              : _hometownController.text,
          workMode: _workModeController.text.isEmpty
              ? null
              : _workModeController.text,
        );

        await AdminService.instance.updateUser(updatedUser);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error updating user: $e")));
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
      ),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit User Profile",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Personal Details"),
                      const SizedBox(height: 16),
                      _buildTextField("Name", _nameController, required: true),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "Age",
                              _ageController,
                              keyboardType: TextInputType.number,
                              required: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              "Height (cm)",
                              _heightController,
                              keyboardType: TextInputType.number,
                              required: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<Gender>(
                              initialValue: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: "Gender",
                              ),
                              items: Gender.values.map((gender) {
                                return DropdownMenuItem(
                                  value: gender,
                                  child: Text(
                                    gender == Gender.male ? "Male" : "Female",
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedGender = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<MaritalStatus>(
                              initialValue: _selectedMaritalStatus,
                              decoration: const InputDecoration(
                                labelText: "Marital Status",
                              ),
                              items: MaritalStatus.values.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status.displayValue),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedMaritalStatus = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        "Location (Working City)",
                        _locationController,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Education & Career"),
                      const SizedBox(height: 16),
                      _buildTextField("Education", _educationController),
                      const SizedBox(height: 12),
                      _buildTextField("Occupation", _occupationController),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "Company",
                              _companyController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField("Income", _incomeController),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField("Work Mode", _workModeController),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Contact Information"),
                      const SizedBox(height: 16),
                      _buildTextField("Phone", _phoneController),
                      const SizedBox(height: 12),
                      _buildTextField(
                        "Email",
                        _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),

                      // Family Details
                      _buildSectionTitle("Family Details"),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "Father's Name",
                              _fatherNameController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              "Mother's Name",
                              _motherNameController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "Siblings",
                              _siblingsController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              "Home Town",
                              _hometownController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Community Details
                      _buildSectionTitle("Community"),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField("Caste", _casteController),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              "Sub-Caste",
                              _subCasteController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Languages"),
                      const SizedBox(height: 16),
                      _buildTextField("Mother Tongue", _motherTongueController),
                      const SizedBox(height: 12),
                      _buildTextField(
                        "Languages (Comma separated)",
                        _languagesController,
                      ),

                      const SizedBox(height: 24),

                      const SizedBox(height: 12),

                      const SizedBox(height: 24),
                      _buildSectionTitle("Bio & Preferences"),
                      const SizedBox(height: 16),
                      _buildTextField("About Me", _bioController, maxLines: 3),
                      const SizedBox(height: 12),
                      _buildTextField(
                        "Partner Preferences",
                        _partnerPreferencesController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Verification"),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text("Verified User"),
                        value: _isVerified,
                        onChanged: (val) => setState(() => _isVerified = val),
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Privacy Settings"),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text("Show Phone Number"),
                        value: _showPhone,
                        onChanged: (val) => setState(() => _showPhone = val),
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                      ),
                      SwitchListTile(
                        title: const Text("Show Email Address"),
                        value: _showEmail,
                        onChanged: (val) => setState(() => _showEmail = val),
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Premium Status"),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text("Is Premium Member"),
                        value: _isPremium,
                        onChanged: (val) => setState(() => _isPremium = val),
                        activeThumbColor: Colors.purple,
                      ),
                      if (_isPremium) ...[
                        const SizedBox(height: 12),
                        _buildTextField(
                          "Premium Expiry Date (YYYY-MM-DD)",
                          _premiumExpiryDateController,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: AppStyles.primaryButtonStyle,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save Changes"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return "Please enter $label";
              }
              return null;
            }
          : null,
    );
  }
}
