import 'package:flutter/material.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'profile_view.dart'; // Usba ang path depende kon asa nimo gibutang

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  
  // 1. Gi-separate na ang controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1D0E),
              Color(0xFFE2FF6F),
            ],
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
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Sign up",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
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
                  color: Colors.black,
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
                        // First Name Field
                        _buildInputField(
                          label: "First Name*",
                          controller: _firstNameController,
                          hint: "Steve",
                        ),
                        const SizedBox(height: 20),
                        // Last Name Field
                        _buildInputField(
                          label: "Last Name*",
                          controller: _lastNameController,
                          hint: "Rogers",
                        ),
                        const SizedBox(height: 20),
                        // Email Field
                        _buildInputField(
                          label: "Email address*",
                          controller: _emailController,
                          hint: "abc@gmail.com",
                        ),
                        const SizedBox(height: 20),
                        // Password Field
                        _buildInputField(
                          label: "Password*",
                          controller: _passwordController,
                          hint: "********",
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),
                        // Confirm Password Field
                        _buildInputField(
                          label: "Confirm Password*",
                          controller: _confirmPasswordController,
                          hint: "********",
                          isPassword: true,
                        ),
                        const SizedBox(height: 40),
                        
                        // Register Button with Fixed Structure
                        Consumer<AuthViewModel>(
                          builder: (context, authVM, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: authVM.isLoading ? null : () {
                                  if (_formKey.currentState!.validate()) {
                                    if (_passwordController.text != _confirmPasswordController.text) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Passwords do not match!")),
                                      );
                                      return;
                                    }
                                    // 2. Navigation logic - moadto sa ProfileView
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ProfileView()),
                                    );
                                    
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE2FF6F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: authVM.isLoading
                                    ? const CircularProgressIndicator(color: Colors.black)
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.auto_awesome, color: Colors.black, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            "Register",
                                            style: TextStyle(
                                              color: Colors.black,
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
                            text: "Already have an account? ",
                            style: const TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: "Login",
                                style: const TextStyle(
                                  color: Colors.white,
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: const Color(0xFF121212),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFE2FF6F)),
            ),
          ),
          validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
        ),
      ],
    );
  }
}