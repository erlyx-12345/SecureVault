import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _loading = false);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/profile');
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
            // UPDATED: Now uses the Lime Green theme for the header gradient
            colors: [
              Color(0xFF1A1D0E), // Very dark olive/black
              Color(0xFFE2FF6F), // The Neon Lime color
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            // Centered Header Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  Text(
                    "Welcome Back",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255), // Darker text looks better on the light neon gradient
                      fontSize: 35, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Step inside and make yourself at home.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color.fromARGB(221, 255, 255, 255), fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: "Email address*",
                          controller: _emailController,
                          hint: "example@gmail.com",
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: "Password*",
                          controller: _passwordController,
                          hint: "@Sn123hsn#",
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text("Forgot Password?", 
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ),
                        const SizedBox(height: 30),
                        
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE2FF6F),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: _loading 
                              ? const CircularProgressIndicator(color: Colors.black)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.auto_awesome, color: Colors.black, size: 20),
                                    SizedBox(width: 8),
                                    Text("Sign in", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                                  ],
                                ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        const Text("Or continue with", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 30),
                        
                        // Social Buttons with colored icons
                        Row(
                          children: [
                            _buildSocialButton(
                              "Google", 
                              Icons.g_mobiledata, 
                              iconColor: Colors.redAccent, // Mimics Google Red
                              isGoogle: true 
                            ),
                            const SizedBox(width: 20),
                            _buildSocialButton(
                              "Facebook", 
                              Icons.facebook, 
                              iconColor: const Color(0xFF1877F2) // Official Facebook Blue
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(text: "Sign up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ]
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required String hint, bool isPassword = false}) {
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
            suffixIcon: isPassword ? const Icon(Icons.visibility_off_outlined, color: Colors.white30) : null,
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

  Widget _buildSocialButton(String label, IconData icon, {required Color iconColor, bool isGoogle = false}) {
    return Expanded(
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white10),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Styled icons to look more like the logos
            Icon(
              icon, 
              color: iconColor, 
              size: isGoogle ? 35 : 28 // Google icon usually needs to be larger to look right
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}