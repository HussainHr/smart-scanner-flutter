import 'package:flutter/material.dart';

abstract final class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    bool isWarning = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isWarning ? const Color(0xFFB45309) : null,
        ),
      );
  }
}
