import 'package:flutter/material.dart';
import '../constants.dart';

class AppSnackBar {
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message,
      AppColors.success,
      Icons.check_circle,
      duration,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _showSnackBar(
      context,
      message,
      AppColors.error,
      Icons.error,
      duration,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message,
      AppColors.warning,
      Icons.warning,
      duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackBar(
      context,
      message,
      AppColors.primaryBlue,
      Icons.info,
      duration,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
    Duration duration,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.white),
            const SizedBox(width: AppDimensions.paddingS),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        margin: const EdgeInsets.all(AppDimensions.paddingM),
      ),
    );
  }
}

class AppDialog {
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.error : AppColors.primaryBlue,
              foregroundColor: AppColors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: AppColors.error),
            const SizedBox(width: AppDimensions.paddingS),
            Text(title),
          ],
        ),
        content: Text(content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  static Future<void> showLoading(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppDimensions.paddingM),
            Text(message),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
      ),
    );
  }
}
