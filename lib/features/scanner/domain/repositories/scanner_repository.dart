import 'package:smart_scanner/features/scanner/domain/entities/barcode_detection.dart';

abstract class ScannerRepository {
  BarcodeDetection? peekPendingDetection();

  BarcodeDetection? consumePendingDetection();

  Future<String> recognizeTextFromFrame();
}
