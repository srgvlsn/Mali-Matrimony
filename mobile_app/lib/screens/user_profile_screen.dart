import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/media_service.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  ImageProvider _getImageProvider(String path) {
    return NetworkImage(ApiService.instance.resolveUrl(path));
  }

  Future<void> _updatePhoto() async {
    final bytes = await MediaService.instance.pickImage(ImageSource.gallery);
    if (bytes == null || !mounted) return;

    final profileService = context.read<ProfileService>();
    final authService = context.read<AuthService>();

    await profileService.updateProfilePhoto(
      bytes,
      'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    authService.refresh();
  }

  Future<void> _editHoroscope() async {
    final authService = context.read<AuthService>();
    final profile = authService.currentUser;
    if (profile == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "Manage Horoscope",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Pick from Gallery"),
              onTap: () async {
                final bytes = await MediaService.instance.pickImage(
                  ImageSource.gallery,
                );
                if (bytes != null && context.mounted) {
                  await context.read<ProfileService>().uploadHoroscope(
                    bytes,
                    'horoscope_${DateTime.now().millisecondsSinceEpoch}.jpg',
                  );
                  if (context.mounted) {
                    authService.refresh();
                    Navigator.pop(context);
                  }
                }
              },
            ),
            if (profile.horoscopeImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Remove Photo",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final updatedProfile = profile.copyWith(
                    horoscopeImageUrl: null,
                  );
                  await context.read<ProfileService>().updateProfile(
                    updatedProfile,
                  );
                  authService.refresh();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _editField(
    String title,
    String label,
    String initialValue,
    Function(String) onSave, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(labelText: label),
          maxLines: title == "Bio" || title == "Partner Preference" ? 3 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _editMaritalStatus(UserProfile profile) {
    MaritalStatus selectedStatus = profile.maritalStatus;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Marital Status"),
          content: DropdownButtonFormField<MaritalStatus>(
            initialValue: selectedStatus,
            items: MaritalStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.displayValue),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setDialogState(() => selectedStatus = val);
              }
            },
            decoration: const InputDecoration(labelText: "Status"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = profile.copyWith(maritalStatus: selectedStatus);
                await context.read<ProfileService>().updateProfile(updated);
                if (context.mounted) {
                  context.read<AuthService>().refresh();
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final profile = authService.currentUser;

        if (profile == null) {
          return const Center(child: Text("Profile not found"));
        }

        final completion = profile.completionPercentage;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (completion >= 1.0)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 14),
                        SizedBox(width: 6),
                        Text(
                          "Profile 100% Completed",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              _buildProfileHeader(
                profile,
                completion,
                profile.photos.isNotEmpty ? profile.photos[0] : null,
              ),
              const SizedBox(height: 32),
              _buildDetailSection("About Me", [
                {
                  "label": "Bio",
                  "value": profile.bio,
                  "onEdit": () => _editField("Bio", "About Me", profile.bio, (
                    val,
                  ) async {
                    final updated = profile.copyWith(bio: val);
                    await context.read<ProfileService>().updateProfile(updated);
                    authService.refresh();
                  }),
                },
              ]),
              const SizedBox(height: 24),
              _buildDetailSection("Partner Preference", [
                {
                  "label": "Expectations",
                  "value": profile.partnerPreferences,
                  "onEdit": () => _editField(
                    "Partner Preference",
                    "What are you looking for?",
                    profile.partnerPreferences,
                    (val) async {
                      final updated = profile.copyWith(partnerPreferences: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
              ]),
              const SizedBox(height: 24),
              _buildDetailSection("Account Information", [
                {
                  "label": "Full Name",
                  "value": profile.name,
                  "onEdit": () => _editField(
                    "Name",
                    "Full Name",
                    profile.name,
                    (val) async {
                      final updated = profile.copyWith(name: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
                {
                  "label": "Phone",
                  "value": profile.phone ?? "Not provided",
                  "onEdit": () => _editField(
                    "Phone",
                    "Phone Number",
                    profile.phone ?? "",
                    (val) async {
                      final updated = profile.copyWith(phone: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
                {
                  "label": "Email",
                  "value": profile.email ?? "Not provided",
                  "onEdit": () => _editField(
                    "Email",
                    "Email Address",
                    profile.email ?? "",
                    (val) async {
                      final updated = profile.copyWith(email: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                },
                {
                  "label": "Location",
                  "value": profile.location,
                  "onEdit": () => _editField(
                    "Location",
                    "City, State",
                    profile.location,
                    (val) async {
                      final updated = profile.copyWith(location: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
                {
                  "label": "Mother Tongue",
                  "value": profile.motherTongue,
                  "onEdit": () => _editField(
                    "Mother Tongue",
                    "Language",
                    profile.motherTongue,
                    (val) async {
                      final updated = profile.copyWith(motherTongue: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
              ]),
              const SizedBox(height: 24),
              _buildDetailSection("Personal Details", [
                {"label": "Gender", "value": profile.gender.name.toUpperCase()},
                {
                  "label": "Age",
                  "value": "${profile.age} yrs",
                  "onEdit": () => _editField(
                    "Age",
                    "Age (years)",
                    profile.age.toString(),
                    (val) async {
                      final age = int.tryParse(val);
                      if (age != null) {
                        final updated = profile.copyWith(age: age);
                        await context.read<ProfileService>().updateProfile(
                          updated,
                        );
                        authService.refresh();
                      }
                    },
                    keyboardType: TextInputType.number,
                  ),
                },
                {
                  "label": "Hometown",
                  "value": profile.hometown ?? "Not provided",
                  "onEdit": () => _editField(
                    "Hometown",
                    "City, State",
                    profile.hometown ?? "",
                    (val) async {
                      final updated = profile.copyWith(hometown: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
                {
                  "label": "Height",
                  "value": "${profile.height.toInt()} cm",
                  "onEdit": () => _editField(
                    "Height",
                    "Height (cm)",
                    profile.height.toInt().toString(),
                    (val) async {
                      final h = double.tryParse(val);
                      if (h != null) {
                        final updated = profile.copyWith(height: h);
                        await context.read<ProfileService>().updateProfile(
                          updated,
                        );
                        authService.refresh();
                      }
                    },
                    keyboardType: TextInputType.number,
                  ),
                },
                {
                  "label": "Marital Status",
                  "value": profile.maritalStatus.displayValue,
                  "onEdit": () => _editMaritalStatus(profile),
                },
              ]),
              const SizedBox(height: 24),
              _buildDetailSection("Community & Education", [
                {
                  "label": "Caste",
                  "value": profile.caste ?? "Not provided",
                  "onEdit": () => _editField(
                    "Caste",
                    "Caste",
                    profile.caste ?? "",
                    (val) async {
                      final updated = profile.copyWith(caste: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
                {
                  "label": "Sub-Caste",
                  "value": profile.subCaste ?? "Not provided",
                  "onEdit": () => _editField(
                    "Sub-Caste",
                    "Sub-Caste",
                    profile.subCaste ?? "",
                    (val) async {
                      final updated = profile.copyWith(subCaste: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
                {
                  "label": "Education",
                  "value": profile.education,
                  "onEdit": () => _editField(
                    "Education",
                    "Qualification",
                    profile.education,
                    (val) async {
                      final updated = profile.copyWith(education: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
                {
                  "label": "Profession",
                  "value": profile.occupation,
                  "onEdit": () => _editField(
                    "Profession",
                    "Work",
                    profile.occupation,
                    (val) async {
                      final updated = profile.copyWith(occupation: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
                {
                  "label": "Company",
                  "value": profile.company,
                  "onEdit": () => _editField(
                    "Company",
                    "Company Name",
                    profile.company,
                    (val) async {
                      final updated = profile.copyWith(company: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
                {
                  "label": "Annual Income",
                  "value": profile.income,
                  "onEdit": () => _editField(
                    "Income",
                    "Annual Income",
                    profile.income,
                    (val) async {
                      final updated = profile.copyWith(income: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
                {
                  "label": "Work Mode",
                  "value": profile.workMode ?? "Office",
                  "onEdit": () => _editField(
                    "Work Mode",
                    "Office/WFH/Hybrid",
                    profile.workMode ?? "Office",
                    (val) async {
                      final updated = profile.copyWith(workMode: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
              ]),
              const SizedBox(height: 24),
              _buildDetailSection("Family Details", [
                {
                  "label": "Father's Name",
                  "value": profile.fatherName,
                  "onEdit": () => _editField(
                    "Father",
                    "Full Name",
                    profile.fatherName,
                    (val) async {
                      final updated = profile.copyWith(fatherName: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
                {
                  "label": "Mother's Name",
                  "value": profile.motherName,
                  "onEdit": () => _editField(
                    "Mother",
                    "Full Name",
                    profile.motherName,
                    (val) async {
                      final updated = profile.copyWith(motherName: val);
                      await context.read<ProfileService>().updateProfile(
                        updated,
                      );
                      authService.refresh();
                    },
                  ),
                },
                {
                  "label": "Siblings",
                  "value": profile.siblings.toString(),
                  "onEdit": () => _editField(
                    "Siblings",
                    "Number of siblings",
                    profile.siblings.toString(),
                    (val) async {
                      final s = int.tryParse(val);
                      if (s != null) {
                        final updated = profile.copyWith(siblings: s);
                        await context.read<ProfileService>().updateProfile(
                          updated,
                        );
                        authService.refresh();
                      }
                    },
                    keyboardType: TextInputType.number,
                  ),
                },
              ]),
              const SizedBox(height: 24),
              _buildAdditionalPhotosSection(profile, authService),
              const SizedBox(height: 24),
              _buildHoroscopeSection(profile),
              const SizedBox(height: 40),
              _buildLogoutButton(context),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(
    UserProfile profile,
    double completion,
    String? imageUrl,
  ) {
    final showProgress = completion < 1.0;

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (showProgress)
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: completion,
                    strokeWidth: 4,
                    color: const Color(0xFF820815),
                    backgroundColor: const Color(
                      0xFF820815,
                    ).withValues(alpha: 0.1),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: showProgress
                        ? Colors.transparent
                        : const Color(0xFF820815),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: imageUrl != null
                      ? _getImageProvider(imageUrl)
                      : null,
                  child: imageUrl == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              if (profile.isVerified)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Consumer<ProfileService>(
                    builder: (context, profileService, child) {
                      final isHighlit = profileService.shouldHighlightBadge;
                      return AnimatedScale(
                        scale: isHighlit ? 1.4 : 1.0,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            boxShadow: isHighlit
                                ? [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      spreadRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _updatePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF820815),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF820815),
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: 8),
            Text(
              "Profile Strength: ${(completion * 100).toInt()}%",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF820815),
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else
            const Text(
              "Premium Member",
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Map<String, dynamic>> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF820815),
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: details
                  .map((detail) => _buildDetailTile(detail))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTile(Map<String, dynamic> detail) {
    return ListTile(
      title: Text(
        detail['label']!,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      subtitle: Text(
        detail['value']!,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: detail['onEdit'] != null
          ? IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: Color(0xFF820815),
              ),
              onPressed: detail['onEdit'],
            )
          : null,
    );
  }

  Widget _buildAdditionalPhotosSection(
    UserProfile profile,
    AuthService authService,
  ) {
    // profile.photos[0] is main photo. Additional are from index 1.
    final additionalPhotos = profile.photos.length > 1
        ? profile.photos.sublist(1)
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Additional Photos (Max 3)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF820815),
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: additionalPhotos.length < 3
                  ? additionalPhotos.length + 1
                  : 3,
              itemBuilder: (context, index) {
                if (index < additionalPhotos.length) {
                  // Photo slot
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image(
                          image: _getImageProvider(additionalPhotos[index]),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () async {
                            await context.read<ProfileService>().removePhoto(
                              index + 1,
                            );
                            authService.refresh();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Add photo slot
                  return GestureDetector(
                    onTap: () async {
                      final bytes = await MediaService.instance.pickImage(
                        ImageSource.gallery,
                      );
                      if (bytes != null && context.mounted) {
                        final success = await context
                            .read<ProfileService>()
                            .addAdditionalPhoto(
                              bytes,
                              'additional_${DateTime.now().millisecondsSinceEpoch}.jpg',
                            );
                        if (success && context.mounted) {
                          authService.refresh();
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Maximum photo limit reached"),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF820815).withValues(alpha: 0.2),
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Color(0xFF820815),
                          size: 32,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoroscopeSection(UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Horoscope",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF820815),
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (profile.horoscopeImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image(
                      image: _getImageProvider(profile.horoscopeImageUrl!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "No horoscope uploaded",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _editHoroscope,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("Edit Horoscope"),
                  style: AppStyles.outlinedButtonStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await AuthService.instance.logout();
        if (!context.mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
      icon: const Icon(Icons.logout),
      label: const Text("Logout"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF820815),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }
}
