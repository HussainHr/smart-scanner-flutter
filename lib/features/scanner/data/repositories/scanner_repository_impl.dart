import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/scanner/data/utils/scan_frame_capture.dart';
import 'package:smart_scanner/features/scanner/domain/entities/barcode_detection.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_frame_layout.dart';
import 'package:smart_scanner/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/scanner_data_providers.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  ScannerRepositoryImpl(this._ref);

  final Ref _ref;

  @override
  BarcodeDetection? peekPendingDetection() {
    return _ref.read(barcodeScannerDatasourceProvider).peekPendingDetection();
  }

  @override
  BarcodeDetection? consumePendingDetection() {
    return _ref
        .read(barcodeScannerDatasourceProvider)
        .consumePendingDetection();
  }

  @override
  Future<String> recognizeTextFromFrame() async {
    final datasource = _ref.read(barcodeScannerDatasourceProvider);
    final imagePath = await ScanFrameCapture.captureCenterFrame(
      boundaryKey: datasource.previewBoundaryKey,
      frameSize: ScanFrameLayout.ocrFrame,
    );

    try {
      return await _ref.read(ocrDatasourceProvider).recognizeFromFile(imagePath);
    } finally {
      final file = File(imagePath);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }
}
