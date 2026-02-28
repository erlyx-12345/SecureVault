import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/social_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // clear error message when user edits fields
    _emailController.addListener(() {
      context.read<AuthViewModel>().clearError();
    });
    _passwordController.addListener(() {
      context.read<AuthViewModel>().clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthViewModel authVM) async {
    if (_formKey.currentState!.validate()) {
      final success = await authVM.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(context, '/profile');
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authVM.errorMessage ?? 'Login failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleGoogleSignIn(AuthViewModel authVM) async {
    final success = await authVM.signInWithGoogle();
    if (mounted) {
      if (success) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authVM.errorMessage ?? AppStrings.googleSignInError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleFacebookSignIn(AuthViewModel authVM) async {
    final success = await authVM.signInWithFacebook();
    if (mounted) {
      if (success) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authVM.errorMessage ?? AppStrings.facebookSignInError,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeVM, _) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: themeVM.isDarkMode
                    ? [AppColors.darkOlive, AppColors.neonLime]
                    : [AppColors.neonLime, AppColors.neonLime],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.loginTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: themeVM.isDarkMode
                              ? AppColors.textPrimary
                              : AppColors.darkBackground,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.loginSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: themeVM.isDarkMode
                              ? AppColors.textSecondary
                              : AppColors.darkBackground.withValues(alpha: 0.7),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.only(
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
                              obscureText: true,
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? AppStrings.required
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            // Show authentication error message inline
                            Consumer<AuthViewModel>(
                              builder: (context, authVM, _) {
                                if (authVM.errorMessage != null &&
                                    authVM.errorMessage!.isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Text(
                                      authVM.errorMessage!,
                                      style: const TextStyle(
                                        color: AppColors.error,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox.shrink(),
                            const SizedBox(height: 30),
                            Consumer<AuthViewModel>(
                              builder: (context, authVM, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: authVM.isLoading
                                        ? null
                                        : () => _handleLogin(authVM),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.neonLime,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      disabledBackgroundColor: Colors.grey,
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
                                                AppStrings.signInButton,
                                                style: TextStyle(
                                                  color:
                                                      AppColors.darkBackground,
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
                            const SizedBox(height: 40),
                            Text(
                              AppStrings.orContinueWith,
                              style: TextStyle(
                                color: themeVM.isDarkMode
                                    ? AppColors.textHint
                                    : AppColors.textHintLight,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Consumer<AuthViewModel>(
                              builder: (context, authVM, child) {
                                return Row(
                                  children: [
                                    SocialButton(
                                      label: AppStrings.googleButton,
                                      icon: Icons.g_mobiledata,
                                      iconColor: Colors.redAccent,
                                      isGoogle: true,
                                      onPressed: () =>
                                          _handleGoogleSignIn(authVM),
                                      isLoading: authVM.isLoading,
                                    ),
                                    const SizedBox(width: 20),
                                    SocialButton(
                                      label: AppStrings.facebookButton,
                                      icon: Icons.facebook,
                                      iconColor: const Color(0xFF1877F2),
                                      onPressed: () =>
                                          _handleFacebookSignIn(authVM),
                                      isLoading: authVM.isLoading,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 40),
                            Text.rich(
                              TextSpan(
                                text: AppStrings.dontHaveAccount,
                                style: TextStyle(
                                  color: themeVM.isDarkMode
                                      ? AppColors.textHint
                                      : AppColors.textHintLight,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppStrings.signUpLink,
                                    style: TextStyle(
                                      color: themeVM.isDarkMode
                                          ? AppColors.textPrimary
                                          : AppColors.textPrimaryLight,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushNamed(
                                          context,
                                          '/register',
                                        );
                                      },
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
      },
    );
  }
}
