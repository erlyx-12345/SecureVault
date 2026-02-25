import 'package:flutter/material.dart';

/// A reusable loading dialog widget for displaying loading states during async operations.
class CustomLoadingDialog {
  /// Show a loading dialog with optional message
  static void show(
    BuildContext context, {
    String message = 'Loading...',
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => barrierDismissible,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF2196F3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Hide the loading dialog
  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Show a success dialog
  static void showSuccess(
    BuildContext context, {
    String title = 'Success',
    String message = 'Operation completed successfully',
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.green[700], size: 24),
              ),
              const SizedBox(width: 12),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss?.call();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show an error dialog
  static void showError(
    BuildContext context, {
    String title = 'Error',
    String message = 'Something went wrong. Please try again.',
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error, color: Colors.red[700], size: 24),
              ),
              const SizedBox(width: 12),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDismiss?.call();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show a confirmation dialog
  static Future<bool> showConfirmation(
    BuildContext context, {
    String title = 'Confirm',
    String message = 'Are you sure?',
    String confirmText = 'Yes',
    String cancelText = 'No',
  }) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
