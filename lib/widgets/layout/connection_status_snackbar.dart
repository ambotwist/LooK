import 'package:flutter/material.dart';
import 'package:lookapp/themes/app_theme.dart';

/// Creates a snackbar for showing connection status messages
SnackBar createConnectionStatusSnackBar({
  required String message,
  required bool isConnected,
  Duration duration = const Duration(seconds: 3),
}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    content: Row(
      children: [
        // WiFi icon that changes based on connection status
        Icon(
          isConnected ? Icons.wifi : Icons.wifi_off,
          color: AppTheme.light.colorScheme.onPrimary,
        ),
        // Spacing between icon and text
        const SizedBox(width: 8),
        // Status message
        Text(
          message,
          style: TextStyle(
            color: AppTheme.light.colorScheme.onPrimary,
          ),
        ),
      ],
    ),
    backgroundColor: AppTheme.light.colorScheme.primary,
    duration: duration,
  );
}
