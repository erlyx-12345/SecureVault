import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';
import 'biometric_setup_view.dart';

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

  bool _isEditing = false;
  final StorageService _storageService = StorageService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _bioController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authVM = context.read<AuthViewModel>();
      final profileVM = context.read<ProfileViewModel>();
      if (authVM.currentUser != null) {
        await profileVM.setUser(authVM.currentUser!);
        await _loadBio(authVM.currentUser!.uid);
      } else {
        await profileVM.initialize();
      }
    });
  }

  Future<void> _loadBio(String userId) async {
    final bio = await _storageService.getUserBio(userId);
    if (mounted) {
      _bioController.text = bio ?? '';
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges(ProfileViewModel profileVM) async {
    if (profileVM.user != null) {
      await _storageService.saveUserBio(
        profileVM.user!.uid,
        _bioController.text.trim(),
      );
    }

    final success = await profileVM.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      bio: _bioController.text.trim(),
    );

    if (mounted) {
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
        setState(() {
          _isEditing = false;
        });

        await profileVM.refreshProfile();

        if (mounted) {
          context.read<AuthViewModel>().initialize();
        }
      } else {
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
    // only clear login flag; keep biometric enabled state for next login
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isloggedin', false);

    await authVM.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _setupBiometric(ProfileViewModel profileVM) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const BiometricSetupView()),
    );

    // If setup was successful, reload profile to reflect biometric status
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric authentication enabled!'),
          backgroundColor: Colors.green,
        ),
      );
      // Reload profile to update biometric status
      await profileVM.initialize();
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<ProfileViewModel>(
        builder: (context, profileVM, _) {
          // Update controllers only when user changes
          if (profileVM.user != null && profileVM.user!.uid != _currentUserId) {
            _currentUserId = profileVM.user!.uid;
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
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors:
                                Theme.of(context).brightness == Brightness.light
                                ? [
                                    AppColors.lightBackground,
                                    AppColors.neonLime,
                                  ]
                                : [
                                    AppColors.darkOlive,
                                    const Color(0xFF2D3516),
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
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: AppColors.neonLime,
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? AppColors.lightSurface
                                    : const Color(0xFF333333),
                                backgroundImage:
                                    profileVM.profileImageUrl != null
                                    ? NetworkImage(profileVM.profileImageUrl!)
                                    : null,
                                child: profileVM.profileImageUrl == null
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppColors.textHintLight
                                            : Colors.white24,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${_firstNameController.text} ${_lastNameController.text}',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.color,
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
                        enabled: false,
                      ),
                      const SizedBox(height: 20),
                      // Dark Mode Toggle Switch
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.brightness_6,
                                  color: AppColors.neonLime,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dark Mode',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium!.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Toggle app appearance',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color!
                                            .withValues(alpha: 0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Builder(
                              builder: (context) {
                                final themeVM = context.watch<ThemeViewModel>();
                                return Switch(
                                  value: themeVM.isDarkMode,
                                  onChanged: (value) =>
                                      themeVM.toggleTheme(value),
                                  activeThumbColor: AppColors.neonLime,
                                  activeTrackColor: AppColors.neonLime
                                      .withValues(alpha: 0.3),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Biometric Toggle Switch
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.fingerprint,
                                  color: AppColors.neonLime,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.enableBiometric,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium!.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Fingerprint/Face ID login',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color!
                                            .withValues(alpha: 0.6),
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
                              activeTrackColor: AppColors.neonLime.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Setup Authentication Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonLime,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () => _setupBiometric(
                            context.read<ProfileViewModel>(),
                          ),
                          icon: const Icon(
                            Icons.fingerprint,
                            color: AppColors.darkBackground,
                            size: 22,
                          ),
                          label: const Text(
                            'Setup Biometric Authentication',
                            style: TextStyle(
                              color: AppColors.darkBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          if (!_isEditing)
                            Expanded(
                              child: SizedBox(
                                height: 55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.neonLime,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: _toggleEditMode,
                                  child: const Text(
                                    'EDIT PROFILE',
                                    style: TextStyle(
                                      color: AppColors.darkBackground,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_isEditing) ...[
                            Expanded(
                              child: SizedBox(
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
                                          color: AppColors.darkBackground,
                                        )
                                      : const Text(
                                          'SAVE CHANGES',
                                          style: TextStyle(
                                            color: AppColors.darkBackground,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 55,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.neonLime,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: _toggleEditMode,
                                  child: const Text(
                                    'CANCEL',
                                    style: TextStyle(
                                      color: AppColors.neonLime,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 15),
                      // LOGOUT BUTTON
                      Consumer<AuthViewModel>(
                        builder: (context, authVM, _) {
                          return SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () => _logout(authVM),
                              icon: const Icon(
                                Icons.logout,
                                color: AppColors.error,
                                size: 20,
                              ),
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
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            readOnly: !_isEditing || !enabled,
            enabled: _isEditing && enabled,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium!.color,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium!.color!.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: AppColors.neonLime, size: 20),
              filled: true,
              fillColor: !_isEditing || !enabled
                  ? Theme.of(context).cardColor.withValues(alpha: 0.5)
                  : null,
              contentPadding: const EdgeInsets.all(18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: AppColors.borderFocus,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    var firstStart = Offset(size.width / 4, size.height);
    var firstEnd = Offset(size.width / 2.25, size.height - 50);
    path.quadraticBezierTo(
      firstStart.dx,
      firstStart.dy,
      firstEnd.dx,
      firstEnd.dy,
    );
    var secondStart = Offset(
      size.width - (size.width / 3.25),
      size.height - 105,
    );
    var secondEnd = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      secondStart.dx,
      secondStart.dy,
      secondEnd.dx,
      secondEnd.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
