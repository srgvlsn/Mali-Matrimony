import 'package:flutter/material.dart';
import 'package:project_mali_matrimony/utils/registration_draft.dart';
import '../services/auth_service.dart';
import '../models/registration_data.dart';
import '../utils/auto_save.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dashboard_screen.dart';

class RegisterStep5Profile extends StatefulWidget {
  final RegistrationData data;

  const RegisterStep5Profile({super.key, required this.data});

  @override
  State<RegisterStep5Profile> createState() => _RegisterStep5ProfileState();
}

class _RegisterStep5ProfileState extends State<RegisterStep5Profile> {
  final aboutMeController = TextEditingController();
  final partnerPreferenceController = TextEditingController();

  File? _profileImage;
  List<File> _additionalImages = [];
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.data.profileImagePath != null) {
      _profileImage = File(widget.data.profileImagePath!);
    }
    if (widget.data.additionalImagePaths != null) {
      _additionalImages = widget.data.additionalImagePaths!
          .map((path) => File(path))
          .toList();
    }
    aboutMeController.text = widget.data.aboutMe ?? '';
    partnerPreferenceController.text = widget.data.partnerPreferences ?? '';
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _pickAdditionalImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _additionalImages.addAll(images.map((x) => File(x.path)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD1C8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF820815)),
          onPressed: () => Navigator.pop(context), // back to Step 4
        ),
      ),
      body: LayoutBuilder(
        builder: (_, constraints) {
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
                          "· Step 5 of 5 ·",
                          style: TextStyle(
                            color: Color(0xFF820815),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        LinearProgressIndicator(
                          value: 5 / 5,
                          minHeight: 6,
                          backgroundColor: Color(0xFFFFB8AB),
                          color: Color(0xFF820815),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        const SizedBox(height: 32),

                        const Text(
                          "Profile Details",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF820815),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Profile Photo Placeholder
                        GestureDetector(
                          onTap: _pickProfileImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFFFFB8AB),
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 32,
                                    color: Color(0xFF820815),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Add Profile Photo (Required)",
                          style: TextStyle(color: Color(0xFF820815)),
                        ),

                        const SizedBox(height: 32),

                        // About Me
                        TextFormField(
                          controller: aboutMeController,
                          maxLines: 4,
                          decoration: _decoration("About Me"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please tell us about yourself";
                            }
                            if (value.length < 20) {
                              return "Please enter at least 20 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Additional Photos (optional placeholder)
                        OutlinedButton.icon(
                          onPressed: _pickAdditionalImages,
                          icon: const Icon(
                            Icons.photo_library,
                            color: Color(0xFF820815),
                          ),
                          label: const Text(
                            "Add Additional Photos (Optional)",
                            style: TextStyle(color: Color(0xFF820815)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF820815)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                        if (_additionalImages.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _additionalImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.file(
                                          _additionalImages[index],
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _additionalImages.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            color: const Color(
                                              0xFF820815,
                                            ).withValues(alpha: 0.7),
                                            child: const Icon(
                                              Icons.close,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Partner Preferences
                        TextFormField(
                          controller: partnerPreferenceController,
                          maxLines: 3,
                          decoration: _decoration("Partner Preferences"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter partner preferences";
                            }
                            if (value.length < 20) {
                              return "Please enter at least 20 characters";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        ElevatedButton(
                          style: _buttonStyle(),
                          onPressed: () async {
                            if (_profileImage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Profile photo is required"),
                                ),
                              );
                              return;
                            }

                            if (_formKey.currentState!.validate()) {
                              // 1️⃣ Save final step data
                              widget.data.aboutMe = aboutMeController.text;
                              widget.data.partnerPreferences =
                                  partnerPreferenceController.text;
                              widget.data.profileImagePath =
                                  _profileImage?.path;
                              widget.data.additionalImagePaths =
                                  _additionalImages.map((f) => f.path).toList();

                              await autoSaveStep(widget.data, 5);

                              // 2️⃣ Call AuthService register
                              final success = await AuthService.instance
                                  .register();

                              if (!mounted) return;

                              // 3️⃣ If registration succeeds
                              if (success) {
                                await RegistrationDraft.clear();
                                if (!mounted) return;

                                Navigator.pushAndRemoveUntil(
                                  this.context,
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            }
                          },
                          child: const Text("Finish Registration"),
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

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF820815)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF820815)),
        borderRadius: BorderRadius.circular(20),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF820815), width: 2),
        borderRadius: BorderRadius.circular(20),
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
