import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_mode.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/inspection_list_notifier.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/scanner_providers.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/camera_preview_widget.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/inspection_list_panel.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/scan_mode_chip.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspectionList = ref.watch(inspectionListProvider);
    final scanMode = ref.watch(scanModeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const CameraPreviewWidget(),
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        ScanModeChip(
                          mode: ScanMode.barcodeQr,
                          isSelected: scanMode == ScanMode.barcodeQr,
                          isEnabled: true,
                        ),
                        const SizedBox(width: 8),
                        ScanModeChip(
                          mode: ScanMode.ocr,
                          isSelected: scanMode == ScanMode.ocr,
                          isEnabled: false,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.85),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 16,
                    child: Center(
                      child: FilledButton.icon(
                        onPressed: () => _handleScan(context, ref),
                        icon: const Icon(Icons.qr_code_scanner_rounded),
                        label: const Text('Scan'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: InspectionListPanel(items: inspectionList),
          ),
        ],
      ),
    );
  }

  void _handleScan(BuildContext context, WidgetRef ref) {
    final detection =
        ref.read(scannerRepositoryProvider).peekPendingDetection();

    if (detection == null) {
      _showMessage(
        context,
        'No code detected. Align the barcode or QR within the frame.',
      );
      return;
    }

    final item = ScanItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      value: detection.value,
      type: detection.type,
      scannedAt: DateTime.now(),
    );

    final result = ref.read(inspectionListProvider.notifier).addScan(item);

    if (result == AddScanResult.duplicate) {
      _showMessage(
        context,
        'Duplicate scan: this code is already in the inspection list.',
        isWarning: true,
      );
      return;
    }

    _showMessage(context, 'Added to inspection list.');
  }

  void _showMessage(
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
