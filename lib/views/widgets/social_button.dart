import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// A rounded button used for social sign‑in (Google / Facebook).
///
/// Parameters allow icon toggling, loading state, and callback.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
    this.isGoogle = false,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;
  final bool isGoogle;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
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
