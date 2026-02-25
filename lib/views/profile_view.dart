import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/constants.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _bioController = TextEditingController();

    // Initialize ProfileViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().initialize();
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveChanges(ProfileViewModel profileVM) async {
    final success = await profileVM.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      bio: _bioController.text.trim(),
      profileImageUrl: _imageFile?.path,
    );

    if (mounted) {
      // ignore: use_build_context_synchronously
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              AppStrings.successProfileUpdate,
              style: TextStyle(
                color: AppColors.darkBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.neonLime,
          ),
        );
        setState(() => _imageFile = null);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileVM.errorMessage ?? 'Update failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _logout(AuthViewModel authVM) async {
    await authVM.logout();
    if (mounted) {
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Consumer<ProfileViewModel>(
        builder: (context, profileVM, _) {
          // Update controllers when user data is loaded
          if (profileVM.user != null && _firstNameController.text.isEmpty) {
            _firstNameController.text = profileVM.firstName;
            _lastNameController.text = profileVM.lastName;
            _emailController.text = profileVM.email;
            _bioController.text = profileVM.bio ?? '';
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        height: 240,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              AppColors.darkOlive,
                              Color(0xFF2D3516),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 55,
                                    backgroundColor: AppColors.neonLime,
                                    child: CircleAvatar(
                                      radius: 52,
                                      backgroundColor: const Color(0xFF333333),
                                      backgroundImage: _imageFile != null
                                          ? FileImage(_imageFile!)
                                          : profileVM.profileImageUrl != null
                                              ? NetworkImage(profileVM.profileImageUrl!)
                                              : null,
                                      child: (_imageFile == null &&
                                              profileVM.profileImageUrl == null)
                                          ? const Icon(Icons.person,
                                              size: 60,
                                              color: Colors.white24)
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.neonLime,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt,
                                          size: 18, color: AppColors.darkBackground),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${_firstNameController.text} ${_lastNameController.text}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      _buildEditableField(
                        label: AppStrings.bioLabel,
                        controller: _bioController,
                        icon: Icons.info_outline,
                        maxLines: 2,
                      ),
                      _buildEditableField(
                        label: 'First Name',
                        controller: _firstNameController,
                        icon: Icons.person_outline,
                      ),
                      _buildEditableField(
                        label: 'Last Name',
                        controller: _lastNameController,
                        icon: Icons.person_outline,
                      ),
                      _buildEditableField(
                        label: 'Email Address',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),
                      // Biometric Toggle Switch
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.fingerprint,
                                    color: AppColors.neonLime, size: 24),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.enableBiometric,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Fingerprint/Face ID login',
                                      style: TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: profileVM.biometricEnabled,
                              onChanged: (value) {
                                profileVM.toggleBiometric(value);
                              },
                              activeThumbColor: AppColors.neonLime,
                              activeTrackColor: AppColors.neonLime.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // SAVE CHANGES BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonLime,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: profileVM.isSaving
                              ? null
                              : () => _saveChanges(profileVM),
                          child: profileVM.isSaving
                              ? const CircularProgressIndicator(
                                  color: AppColors.darkBackground)
                              : const Text(
                                  AppStrings.saveChanges,
                                  style: TextStyle(
                                    color: AppColors.darkBackground,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // LOGOUT BUTTON
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) {
                          return SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () => _logout(authVM),
                              icon: const Icon(Icons.logout,
                                  color: AppColors.error, size: 20),
                              label: const Text(
                                AppStrings.logoutButton,
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String hint = '',
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppColors.neonLime, size: 20),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              contentPadding: const EdgeInsets.all(18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppColors.borderFocus,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CLIPPER CLASS (Wave Background)
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    var firstStart = Offset(size.width / 4, size.height);
    var firstEnd = Offset(size.width / 2.25, size.height - 50);
    path.quadraticBezierTo(firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);
    var secondStart = Offset(size.width - (size.width / 3.25), size.height - 105);
    var secondEnd = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
        secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
