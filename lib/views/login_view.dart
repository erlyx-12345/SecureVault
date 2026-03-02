import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _showBiometric = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthViewModel>().clearError();
    });

    _emailController.addListener(() {
      context.read<AuthViewModel>().clearError();
    });
    _passwordController.addListener(() {
      context.read<AuthViewModel>().clearError();
    });

    // Check if biometric should be shown
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    final isBiometricEnabled = prefs.getBool('isbiometricenabled') ?? false;

    if (mounted) {
      setState(() {
        // show biometric button if user previously enabled it
        _showBiometric = isBiometricEnabled;
      });
    }

    // trigger a one‑time biometric login attempt
    if (isBiometricEnabled && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // clear any previous biometric error message before trying
        context.read<AuthViewModel>().clearError();
        _attemptBiometricLogin();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyLogged = prefs.getBool('isloggedin') ?? false;
    if (alreadyLogged) return; // avoid rerunning after a normal login

    final authVM = context.read<AuthViewModel>();
    // reset error if the user cancelled previously
    authVM.clearError();
    final success = await authVM.authenticateWithBiometric();
    if (success && mounted) {
      final prefs2 = await SharedPreferences.getInstance();
      await prefs2.setBool('isloggedin', true);
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  Future<void> _handleLogin(AuthViewModel authVM) async {
    if (_formKey.currentState!.validate()) {
      final success = await authVM.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          // Set isloggedin flag in shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isloggedin', true);

          Navigator.pushReplacementNamed(context, '/profile');
        } else {
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
    try {
      final success = await authVM.signInWithGoogle();
      print('[LoginView] Google sign-in returned $success, currentUser=${authVM.currentUser} error=${authVM.errorMessage}');
      if (!mounted) return;

      if (success) {
        // Set isloggedin flag in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isloggedin', true);

        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authVM.errorMessage ?? AppStrings.googleSignInError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      print('[LoginView] Exception during Google sign-in: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleFacebookSignIn(AuthViewModel authVM) async {
    final success = await authVM.signInWithFacebook();
    if (!mounted) return;

    if (success) {
      // Set isloggedin flag in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isloggedin', true);

      Navigator.pushReplacementNamed(context, '/profile');
      return;
    }

    if (authVM.pendingFacebookCredential != null) {
      _showConflictDialog(authVM);
    } else {
      if (authVM.errorMessage != null &&
          authVM.errorMessage!.toLowerCase().contains('cancel')) {
      } else {
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

  void _showConflictDialog(AuthViewModel authVM) {
    final providers = authVM.pendingEmailProviders ?? [];
    final email = authVM.pendingEmail ?? '';
    final providerNames = providers
        .map(
          (p) => p == 'password'
              ? 'Email/Password'
              : p == 'google.com'
              ? 'Google'
              : p,
        )
        .join(', ');

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Account Conflict'),
          content: Text(
            'An account already exists for $email using the following provider(s):\n$providerNames.\n'
            'Please sign in using one of those providers; once you do the Facebook '
            'account will automatically be linked.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
                            // Biometric authentication button
                            if (_showBiometric)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: GestureDetector(
                                  onTap: _attemptBiometricLogin,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.neonLime,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.fingerprint,
                                          color: AppColors.neonLime,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Tap to login with biometric',
                                          style: TextStyle(
                                            color: AppColors.neonLime,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
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
