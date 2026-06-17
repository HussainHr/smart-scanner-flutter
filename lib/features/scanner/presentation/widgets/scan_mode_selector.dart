import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_mode.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/scanner_providers.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scan_mode_chip.dart';

class ScanModeSelector extends ConsumerWidget {
  const ScanModeSelector({
    super.key,
    required this.isEnabled,
  });

  final bool isEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanMode = ref.watch(scanModeProvider);

    return Row(
      children: [
        ScanModeChip(
          mode: ScanMode.barcodeQr,
          isSelected: scanMode == ScanMode.barcodeQr,
          isEnabled: isEnabled,
          onTap: () => ref
              .read(scanModeProvider.notifier)
              .setMode(ScanMode.barcodeQr),
        ),
        const SizedBox(width: 8),
        ScanModeChip(
          mode: ScanMode.ocr,
          isSelected: scanMode == ScanMode.ocr,
          isEnabled: isEnabled,
          onTap: () => ref.read(scanModeProvider.notifier).setMode(ScanMode.ocr),
        ),
      ],
    );
  }
}
