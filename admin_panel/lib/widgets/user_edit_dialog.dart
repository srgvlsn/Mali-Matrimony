import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../services/admin_mock_service.dart';

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

  late Gender _selectedGender;
  late MaritalStatus _selectedMaritalStatus;
  late bool _isVerified;

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

    _selectedGender = widget.user.gender;
    _selectedMaritalStatus = widget.user.maritalStatus;
    _isVerified = widget.user.isVerified;
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
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedUser = widget.user.copyWith(
        name: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        gender: _selectedGender,
        maritalStatus: _selectedMaritalStatus,
        education: _educationController.text,
        occupation: _occupationController.text,
        company: _companyController.text,
        income: _incomeController.text,
        location: _locationController.text,
        bio: _bioController.text,
        partnerPreferences: _partnerPreferencesController.text,
        isVerified: _isVerified,
      );

      AdminMockService.instance.updateUser(updatedUser);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Edit User Profile",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.primary,
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
                      _buildSectionTitle("Personal Information"),
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
                                  child: Text(gender.name.toUpperCase()),
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
                      _buildTextField("Location", _locationController),
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
                        activeThumbColor: AppStyles.primary,
                      ),
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
                  onPressed: _saveChanges,
                  style: AppStyles.primaryButtonStyle,
                  child: const Text("Save Changes"),
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppStyles.primary,
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
