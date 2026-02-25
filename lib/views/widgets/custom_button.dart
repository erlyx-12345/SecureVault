import 'package:flutter/material.dart';

/// A reusable custom button widget that supports multiple button types and states.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final ButtonType type;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final bool isEnabled;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.width,
    this.height,
    this.padding,
    this.icon,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: _buildButtonByType(),
    );
  }

  Widget _buildButtonByType() {
    return switch (type) {
      ButtonType.primary => _buildPrimaryButton(),
      ButtonType.secondary => _buildSecondaryButton(),
      ButtonType.outline => _buildOutlineButton(),
      ButtonType.danger => _buildDangerButton(),
    };
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton(
      onPressed: isLoading || !isEnabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2196F3),
        disabledBackgroundColor: Colors.grey[400],
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _buildButtonContent(Colors.white),
    );
  }

  Widget _buildSecondaryButton() {
    return ElevatedButton(
      onPressed: isLoading || !isEnabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        disabledBackgroundColor: Colors.grey[300],
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _buildButtonContent(Colors.black87),
    );
  }

  Widget _buildOutlineButton() {
    return OutlinedButton(
      onPressed: isLoading || !isEnabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isEnabled ? const Color(0xFF2196F3) : Colors.grey,
          width: 1.5,
        ),
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _buildButtonContent(const Color(0xFF2196F3)),
    );
  }

  Widget _buildDangerButton() {
    return ElevatedButton(
      onPressed: isLoading || !isEnabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[700],
        disabledBackgroundColor: Colors.red[200],
        padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _buildButtonContent(Colors.white),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}

enum ButtonType { primary, secondary, outline, danger }
