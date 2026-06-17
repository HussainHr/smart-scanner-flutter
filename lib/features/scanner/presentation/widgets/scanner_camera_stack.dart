import 'package:flutter/material.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_mode.dart';

class ScannerCameraStack extends StatelessWidget {
  const ScannerCameraStack({
    super.key,
    required this.cameraPreview,
    required this.modeSelector,
    required this.scanMode,
    required this.isProcessing,
    required this.isSaving,
    required this.onScanPressed,
  });

  final Widget cameraPreview;
  final Widget modeSelector;
  final ScanMode scanMode;
  final bool isProcessing;
  final bool isSaving;
  final VoidCallback onScanPressed;

  @override
  Widget build(BuildContext context) {
    final isOcrMode = scanMode == ScanMode.ocr;
    final isBusy = isProcessing || isSaving;

    return Stack(
      fit: StackFit.expand,
      children: [
        cameraPreview,
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: modeSelector,
        ),
        Center(
          child: Container(
            width: 220,
            height: isOcrMode ? 180 : 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        if (isOcrMode)
          Positioned(
            top: 56,
            left: 24,
            right: 24,
            child: Text(
              'Align text inside the frame only.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        Positioned(
          left: 10,
          right: 10,
          bottom: 14,
          child: Center(
            child: FilledButton.icon(
              onPressed: isBusy ? null : onScanPressed,
              icon: Icon(
                isOcrMode
                    ? Icons.document_scanner_outlined
                    : Icons.qr_code_scanner_rounded,
              ),
              label: Text(isOcrMode ? 'Scan Text' : 'Scan'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        if (isProcessing)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
