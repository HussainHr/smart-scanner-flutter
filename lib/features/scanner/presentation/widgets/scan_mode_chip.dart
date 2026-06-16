import 'package:flutter/material.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEnabled) ...[
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                mode.label,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.primary
                      : Colors.white.withValues(alpha: isEnabled ? 0.95 : 0.65),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
