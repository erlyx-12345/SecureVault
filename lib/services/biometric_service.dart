import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isBiometricDeviceSupported() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
      );
    } catch (e) {
      return false;
    }
  }

  /// Check if biometrics are available on device and if fingerprints are registered.
  /// Returns null if available and registered, error message if not available.
  Future<String?> checkBiometricAvailability() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) {
        return 'Biometric authentication is not available on this device';
      }

      final availableBiometrics = await _auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return 'No biometric (fingerprint/face) is registered. Please register one in device settings.';
      }

      return null; // biometrics are available and registered
    } catch (e) {
      return 'Error checking biometric availability: ${e.toString()}';
    }
  }
}

// Biometric authentication handler class
class Biometricauth {
  final auth = LocalAuthentication();
  final biometricService = BiometricService();

  Future<void> checkBiometric(
      context, Widget? successscreen, Widget? failscreen, bool? issetup) async {
    // Check if biometrics are available and registered
    final availabilityError = await biometricService.checkBiometricAvailability();

    if (availabilityError != null) {
      // Show error and guide user
      if (issetup == true) {
        // During setup, guide user to register biometric
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Setup Biometric Authentication'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(availabilityError),
                  const SizedBox(height: 16),
                  const Text(
                    'Steps to register a fingerprint:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Go to Settings\n'
                    '2. Find Biometrics or Security Settings\n'
                    '3. Add a new fingerprint\n'
                    '4. Return to this screen and try again',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        // During login, show error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(availabilityError),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    // Biometrics are available - proceed with authentication
    bool authenticated = await auth.authenticate(
      localizedReason: 'Scan your fingerprint to authenticate',
    );

    if (authenticated) {
      if (issetup == true) {
        // Save biometric enabled flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isbiometricenabled', true);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication enabled!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Close dialog
        }
      }
    } else {
      if (failscreen != null && context.mounted) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => failscreen));
      }
    }
  }
}