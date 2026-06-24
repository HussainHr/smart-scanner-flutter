import 'package:flutter/material.dart';
import 'package:smart_scanner/core/theme/app_theme.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_mode.dart';

class ScanModeChip extends StatelessWidget {
  const ScanModeChip({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.isEnabled,
    this.onTap,
  });

  final ScanMode mode;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.scannerTeal : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppTheme.scannerMint
                    : AppTheme.scannerInputBorder,
              ),
            ),
            child: Text(
              mode.label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: isEnabled ? 0.85 : 0.45),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
