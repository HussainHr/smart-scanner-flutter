import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_scanner/features/scanner/data/utils/barcode_detection_selector.dart';
import 'package:smart_scanner/features/scanner/data/utils/barcode_value_normalizer.dart';
import 'package:smart_scanner/features/scanner/domain/entities/barcode_detection.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';

typedef BarcodeDetectionCallback = void Function(BarcodeDetection detection);

class BarcodeScannerDatasource {
  BarcodeScannerDatasource({this.onDetectionUpdated}) {
    previewBoundaryKey = GlobalKey();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 500,
      facing: CameraFacing.back,
      returnImage: true,
      formats: const [
        BarcodeFormat.codabar,
        BarcodeFormat.code39,
        BarcodeFormat.code128,
        BarcodeFormat.code93,
        BarcodeFormat.qrCode,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
        BarcodeFormat.dataMatrix,
        BarcodeFormat.pdf417,
        BarcodeFormat.aztec,
      ],
    );
  }

  final BarcodeDetectionCallback? onDetectionUpdated;

  late final MobileScannerController _controller;
  late final GlobalKey previewBoundaryKey;

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

    final barcode = BarcodeDetectionSelector.selectBest(capture.barcodes);
    if (barcode == null) {
      return;
    }

    final rawValue = barcode.rawValue?.trim();
    final displayValue = barcode.displayValue?.trim();
    final source = rawValue?.isNotEmpty == true
        ? rawValue!
        : displayValue?.isNotEmpty == true
            ? displayValue!
            : null;
    if (source == null) {
      return;
    }

    final normalized =
        BarcodeValueNormalizer.normalize(source, barcode.format);
    if (normalized.isEmpty) {
      return;
    }

    final detection = BarcodeDetection(
      value: normalized,
      type: _mapFormat(barcode.format),
    );

    final valueChanged = _latestDetection?.value != detection.value;
    _latestDetection = detection;

    if (valueChanged) {
      onDetectionUpdated?.call(detection);
    }
  }

  BarcodeDetection? peekPendingDetection() => _latestDetection;

  BarcodeDetection? consumePendingDetection() {
    final detection = _latestDetection;
    _latestDetection = null;
    return detection;
  }

  void clearPendingDetection() {
    _latestDetection = null;
  }

  ScanType _mapFormat(BarcodeFormat format) {
    return switch (format) {
      BarcodeFormat.qrCode ||
      BarcodeFormat.dataMatrix ||
      BarcodeFormat.aztec =>
        ScanType.qr,
      _ => ScanType.barcode,
    };
  }

  Future<void> release() async {
    if (_controller.value.isRunning) {
      await _controller.stop();
    }

    await _controller.dispose();
  }
}
