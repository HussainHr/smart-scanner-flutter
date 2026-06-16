import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_scanner/features/scanner/data/datasources/barcode_scanner_datasource.dart';

class BarcodeCameraPreview extends StatelessWidget {
  const BarcodeCameraPreview({
    super.key,
    required this.datasource,
  });

  final BarcodeScannerDatasource datasource;

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: datasource.controller,
      onDetect: datasource.handleDetection,
      errorBuilder: (context, error, child) {
        if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
          return _CameraPermissionView(
            onRetry: datasource.requestCameraAccess,
          );
        }

        return ColoredBox(
          color: Colors.black,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                error.errorCode.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CameraPermissionView extends StatelessWidget {
  const _CameraPermissionView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: const Color(0xFF0F172A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off_rounded,
                size: 48,
                color: colorScheme.primary.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 16),
              const Text(
                'Camera permission required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Allow camera access to scan barcodes and QR codes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
