import 'package:flutter/material.dart';
import '../utils/registration_draft.dart';
import '../services/auth_service.dart';
import '../models/registration_data.dart';
import '../utils/auto_save.dart';
import 'package:shared/shared.dart';
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

  bool _isLoading = false;
  File? _profileImage;
  File? _horoscopeImage;
  List<File> _additionalImages = [];
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.data.profileImagePath != null) {
      _profileImage = File(widget.data.profileImagePath!);
    }
    if (widget.data.horoscopeImagePath != null) {
      _horoscopeImage = File(widget.data.horoscopeImagePath!);
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
    if (_additionalImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can only add up to 3 additional photos"),
        ),
      );
      return;
    }

    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        final remainingSlots = 3 - _additionalImages.length;
        if (images.length > remainingSlots) {
          _additionalImages.addAll(
            images.take(remainingSlots).map((x) => File(x.path)),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Only the first 3 additional photos were added"),
            ),
          );
        } else {
          _additionalImages.addAll(images.map((x) => File(x.path)));
        }
      });
    }
  }

  Future<void> _pickHoroscopeImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _horoscopeImage = File(image.path);
      });
    }
  }

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
          onPressed: () => Navigator.pop(context), // back to Step 4
        ),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
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
                            Text(
                              "· Step 5 of 5 ·",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),

                            LinearProgressIndicator(
                              value: 5 / 5,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFFFB8AB),
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(
                                AppStyles.radiusFull,
                              ),
                            ),
                            const SizedBox(height: 32),

                            Text(
                              "Profile Details",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
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
                                    ? Icon(
                                        Icons.camera_alt,
                                        size: 32,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Add Profile Photo (Required)",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // About Me
                            TextFormField(
                              controller: aboutMeController,
                              minLines: 1,
                              maxLines: 5,
                              decoration: InputDecoration(
                                labelText: "About Me",
                              ),
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
                                // Icon color handled by style
                              ),
                              label: const Text(
                                "Add Additional Photos (Max 3)",
                                // Text color handled by style
                              ),
                              style: AppStyles.outlinedButtonStyle,
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
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              AppStyles.radiusM,
                                            ),
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
                                                  _additionalImages.removeAt(
                                                    index,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.7),
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

                            const SizedBox(height: 16),
                            // Horoscope Upload
                            OutlinedButton.icon(
                              onPressed: _pickHoroscopeImage,
                              icon: const Icon(Icons.auto_awesome),
                              label: Text(
                                _horoscopeImage == null
                                    ? "Add Horoscope (Optional)"
                                    : "Change Horoscope",
                              ),
                              style: AppStyles.outlinedButtonStyle,
                            ),
                            if (_horoscopeImage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppStyles.radiusS,
                                  ),
                                  child: Image.file(
                                    _horoscopeImage!,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Partner Preferences
                            TextFormField(
                              controller: partnerPreferenceController,
                              minLines: 1,
                              maxLines: 5,
                              decoration: InputDecoration(
                                labelText: "Partner Preferences",
                              ),
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
                              style: AppStyles.primaryButtonStyle,
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (_profileImage == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Profile photo is required",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        try {
                                          // 1️⃣ Upload Images
                                          setState(() => _isLoading = true);

                                          // Profile Image
                                          if (_profileImage != null) {
                                            final bytes = await _profileImage!
                                                .readAsBytes();
                                            final response =
                                                await BackendService.instance
                                                    .uploadImage(
                                                      bytes,
                                                      _profileImage!.path
                                                          .split('/')
                                                          .last,
                                                    );
                                            if (response.success &&
                                                response.data != null) {
                                              widget.data.profileImagePath =
                                                  response.data;
                                            } else {
                                              throw Exception(
                                                "Profile photo upload failed: ${response.message}",
                                              );
                                            }
                                          }

                                          // Horoscope Image
                                          if (_horoscopeImage != null) {
                                            final bytes = await _horoscopeImage!
                                                .readAsBytes();
                                            final response =
                                                await BackendService.instance
                                                    .uploadImage(
                                                      bytes,
                                                      _horoscopeImage!.path
                                                          .split('/')
                                                          .last,
                                                    );
                                            if (response.success &&
                                                response.data != null) {
                                              widget.data.horoscopeImagePath =
                                                  response.data;
                                            }
                                          }

                                          // Additional Images
                                          if (_additionalImages.isNotEmpty) {
                                            final List<String> uploadedUrls =
                                                [];
                                            for (var file
                                                in _additionalImages) {
                                              final bytes = await file
                                                  .readAsBytes();
                                              final response =
                                                  await BackendService.instance
                                                      .uploadImage(
                                                        bytes,
                                                        file.path
                                                            .split('/')
                                                            .last,
                                                      );
                                              if (response.success &&
                                                  response.data != null) {
                                                uploadedUrls.add(
                                                  response.data!,
                                                );
                                              }
                                            }
                                            widget.data.additionalImagePaths =
                                                uploadedUrls;
                                          }

                                          // 2️⃣ Save final step data (strings only now)
                                          widget.data.aboutMe =
                                              aboutMeController.text;
                                          widget.data.partnerPreferences =
                                              partnerPreferenceController.text;

                                          await autoSaveStep(widget.data, 5);

                                          // 3️⃣ Call AuthService register
                                          final response = await AuthService
                                              .instance
                                              .register(widget.data);

                                          if (!context.mounted) return;

                                          // 4️⃣ Handle Response
                                          if (response.success) {
                                            await RegistrationDraft.clear();
                                            if (!context.mounted) return;

                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const DashboardScreen(),
                                              ),
                                              (route) => false,
                                            );
                                          } else {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  response.message ??
                                                      "Registration failed. Please try again.",
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text("Error: $e"),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() => _isLoading = false);
                                          }
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
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
