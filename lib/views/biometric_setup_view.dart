import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/biometric_service.dart';
import '../utils/constants.dart';

class BiometricSetupView extends StatefulWidget {
  const BiometricSetupView({super.key});

  @override
  State<BiometricSetupView> createState() => _BiometricSetupViewState();
}

class _BiometricSetupViewState extends State<BiometricSetupView> {
  final BiometricService _biometricService = BiometricService();
  bool _isScanning = false;
  String _statusMessage = '';
  bool _setupSuccess = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final availabilityError =
        await _biometricService.checkBiometricAvailability();
    if (availabilityError != null) {
      setState(() {
        _statusMessage = availabilityError;
      });
    }
  }

  Future<void> _registerFingerprint() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Waiting for fingerprint scanner...';
    });

    try {
      // Call authenticate which shows the system's native biometric UI
      // The device's fingerprint dialog will appear - use it to scan
      final authenticated = await _biometricService.authenticate();

      if (authenticated) {
        // Save biometric enabled flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isbiometricenabled', true);

        if (mounted) {
          setState(() {
            _setupSuccess = true;
            _statusMessage = 'Fingerprint registered successfully!';
            _isScanning = false;
          });

          // Stay on success screen for 2 seconds then go back
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pop(context, true); // Return true to indicate success
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isScanning = false;
            _statusMessage =
                'Fingerprint registration cancelled. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _statusMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Biometric Authentication'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Large fingerprint icon
              Icon(
                Icons.fingerprint,
                size: 100,
                color: _setupSuccess ? Colors.green : AppColors.neonLime,
              ),
              const SizedBox(height: 30),
              // Title
              Text(
                _setupSuccess
                    ? 'Setup Complete!'
                    : 'Register Your Fingerprint',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Description
              Text(
                _setupSuccess
                    ? 'Your fingerprint has been registered. You can now use it to quickly log in to SecureVault.'
                    : 'Place your finger on the scanner below to register your fingerprint for quick and secure login.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              // Scanning animation / Status
              if (_isScanning)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Using your device\'s fingerprint scanner...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.neonLime,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.neonLime),
                      ),
                    ),
                  ],
                )
              else if (_setupSuccess)
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.greenAccent,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              const SizedBox(height: 30),
              // Status text
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _setupSuccess
                      ? Colors.green
                      : (_isScanning ? AppColors.neonLime : AppColors.error),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 50),
              // Register button
              if (!_isScanning && !_setupSuccess)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _statusMessage.startsWith('No biometric')
                        ? null
                        : _registerFingerprint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonLime,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Register Fingerprint',
                      style: TextStyle(
                        color: AppColors.darkBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              if (_setupSuccess)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              // Help text
              if (!_setupSuccess)
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Tips for Registration'),
                        content: const Text(
                          '• Make sure your finger is clean and dry\n'
                          '• Place your finger flat on the scanner\n'
                          '• Press gently and wait for confirmation\n'
                          '• You can register multiple fingerprints in device settings',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Need help? Tap here for tips',
                    style: TextStyle(
                      color: AppColors.neonLime,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
