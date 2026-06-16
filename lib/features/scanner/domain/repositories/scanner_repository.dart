import 'package:smart_scanner/features/scanner/domain/entities/barcode_detection.dart';

abstract class ScannerRepository {
  BarcodeDetection? peekPendingDetection();

  Future<String> recognizeTextFromFrame();
}
