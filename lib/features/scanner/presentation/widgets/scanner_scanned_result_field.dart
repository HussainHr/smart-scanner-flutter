import 'package:flutter/material.dart';
import 'package:smart_scanner/core/theme/app_theme.dart';

class ScannerScannedResultField extends StatelessWidget {
  const ScannerScannedResultField({
    super.key,
    required this.code,
  });

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.scannerInputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.scannerInputBorder),
      ),
      child: Text(
        code.isEmpty ? '—' : code,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: code.isEmpty
              ? Colors.white.withValues(alpha: 0.35)
              : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}
