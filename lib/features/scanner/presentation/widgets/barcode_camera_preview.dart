import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_scanner/features/scanner/data/datasources/barcode_scanner_datasource.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_frame_layout.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_mode.dart';
import 'package:smart_scanner/features/scanner/presentation/widgets/camera_permission_view.dart';

class BarcodeCameraPreview extends StatefulWidget {
  const BarcodeCameraPreview({
    super.key,
    required this.datasource,
    required this.scanMode,
  });

  final BarcodeScannerDatasource datasource;
  final ScanMode scanMode;

  @override
  State<BarcodeCameraPreview> createState() => _BarcodeCameraPreviewState();
}

class _BarcodeCameraPreviewState extends State<BarcodeCameraPreview> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.datasource.requestCameraAccess();
    });
  }

  @override
  Widget build(BuildContext context) {
    final frameSize = ScanFrameLayout.frameForMode(
      widget.scanMode == ScanMode.ocr,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final scanWindow = _buildScanWindow(constraints.biggest, frameSize);

        return RepaintBoundary(
          key: widget.datasource.previewBoundaryKey,
          child: MobileScanner(
            controller: widget.datasource.controller,
            onDetect: widget.datasource.handleDetection,
            scanWindow: scanWindow,
            errorBuilder: (context, error, child) {
              if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                return CameraPermissionView(
                  onRetry: widget.datasource.requestCameraAccess,
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
          ),
        );
      },
    );
  }

  Rect _buildScanWindow(Size previewSize, Size frameSize) {
    final left = (previewSize.width - frameSize.width) / 2;
    final top = (previewSize.height - frameSize.height) / 2;

    return Rect.fromLTWH(
      left.clamp(0, previewSize.width),
      top.clamp(0, previewSize.height),
      frameSize.width.clamp(0, previewSize.width),
      frameSize.height.clamp(0, previewSize.height),
    );
  }
}
