import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_scanner/features/scanner/domain/entities/barcode_detection.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';

class BarcodeScannerDatasource {
  BarcodeScannerDatasource() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: const [
        BarcodeFormat.qrCode,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.dataMatrix,
        BarcodeFormat.pdf417,
        BarcodeFormat.aztec,
      ],
    );
  }

  late final MobileScannerController _controller;
  BarcodeDetection? _latestDetection;

  MobileScannerController get controller => _controller;

  Future<void> requestCameraAccess() async {
    if (_controller.value.isRunning) {
      return;
    }

    await _controller.start();
  }

  void handleDetection(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) {
      return;
    }

    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue?.trim();

    if (rawValue == null || rawValue.isEmpty) {
      return;
    }

    _latestDetection = BarcodeDetection(
      value: rawValue,
      type: _mapFormat(barcode.format),
    );
  }

  BarcodeDetection? getLatestDetection() => _latestDetection;

  ScanType _mapFormat(BarcodeFormat format) {
    return switch (format) {
      BarcodeFormat.qrCode ||
      BarcodeFormat.dataMatrix ||
      BarcodeFormat.aztec =>
        ScanType.qr,
      _ => ScanType.barcode,
    };
  }

  Future<void> dispose() async {
    await _controller.dispose();
  }
}
