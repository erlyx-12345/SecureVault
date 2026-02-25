import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
    return Scaffold(
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
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  Text(
                    AppStrings.loginTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    AppStrings.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: AppStrings.emailLabel,
                          controller: _emailController,
                          hint: AppStrings.emailHint,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: AppStrings.passwordLabel,
                          controller: _passwordController,
                          hint: AppStrings.passwordHint,
                          isPassword: true,
                          validator: (value) => (value == null || value.isEmpty)
                              ? AppStrings.required
                              : null,
                        ),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            AppStrings.forgotPassword,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
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
                        const SizedBox(height: 40),
                        const Text(
                          AppStrings.orContinueWith,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        Consumer<AuthViewModel>(
                          builder: (context, authVM, child) {
                            return Row(
                              children: [
                                _buildSocialButton(
                                  AppStrings.googleButton,
                                  Icons.g_mobiledata,
                                  iconColor: Colors.redAccent,
                                  isGoogle: true,
                                  onPressed: () =>
                                      _handleGoogleSignIn(authVM),
                                  isLoading: authVM.isLoading,
                                ),
                                const SizedBox(width: 20),
                                _buildSocialButton(
                                  AppStrings.facebookButton,
                                  Icons.facebook,
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
                            style: const TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: AppStrings.signUpLink,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, '/register');
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
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.charcoal,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textHint,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.borderFocus),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    String label,
    IconData icon, {
    required Color iconColor,
    bool isGoogle = false,
    required VoidCallback onPressed,
    required bool isLoading,
  }) {
    return Expanded(
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.borderLight),
          color: Colors.transparent,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: isGoogle ? 35 : 28),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
