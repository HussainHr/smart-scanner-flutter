import 'package:flutter/material.dart';

Future<bool> showDeleteFileDialog(
  BuildContext context,
  String fileName,
) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete file?'),
        content: Text('Delete $fileName from saved files?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return shouldDelete ?? false;
}
