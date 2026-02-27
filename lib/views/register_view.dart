import 'package:flutter/material.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister(AuthViewModel authVM) async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.passwordMismatch),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final success = await authVM.registerWithEmail(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          // registration succeeded; update profile VM as well so that
          // profile view immediately has the new user data.
          // (we'll set it again below before navigation)

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.successRegistration),
              backgroundColor: AppColors.success,
            ),
          );
          // Before navigating to profile we make sure the ProfileViewModel
          // has the latest user object (it should already via listeners but
          // doing it explicitly avoids timing issues).
          if (mounted) {
            final profileVM = context.read<ProfileViewModel>();
            if (authVM.currentUser != null) {
              await profileVM.setUser(authVM.currentUser!);
            }
          }

          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(
            context,
            '/profile',
            arguments: {
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
              'email': _emailController.text.trim(),
            },
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authVM.errorMessage ?? 'Registration failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.darkOlive, AppColors.neonLime],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      AppStrings.registerTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.darkBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        CustomTextField(
                          label: AppStrings.firstNameLabel,
                          controller: _firstNameController,
                          hint: AppStrings.firstNameHint,
                          validator: Validators.validateFullName,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: AppStrings.lastNameLabel,
                          controller: _lastNameController,
                          hint: AppStrings.lastNameHint,
                          validator: Validators.validateFullName,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: AppStrings.emailLabel,
                          controller: _emailController,
                          hint: AppStrings.emailHint,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: AppStrings.passwordLabel,
                          controller: _passwordController,
                          hint: AppStrings.passwordHint,
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onTogglePassword: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: AppStrings.confirmPasswordLabel,
                          controller: _confirmPasswordController,
                          hint: AppStrings.confirmPasswordHint,
                          isPassword: true,
                          obscureText: _obscureConfirmPassword,
                          onTogglePassword: () {
                            setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            );
                          },
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                        ),
                        const SizedBox(height: 40),
                        Consumer<AuthViewModel>(
                          builder: (context, authVM, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: authVM.isLoading
                                    ? null
                                    : () => _handleRegister(authVM),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neonLime,
                                  disabledBackgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: authVM.isLoading
                                    ? const CircularProgressIndicator(
                                        color: AppColors.darkBackground,
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.auto_awesome,
                                            color: AppColors.darkBackground,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            AppStrings.registerButton,
                                            style: TextStyle(
                                              color: AppColors.darkBackground,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        Text.rich(
                          TextSpan(
                            text: AppStrings.alreadyHaveAccount,
                            style: const TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: AppStrings.loginLink,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
