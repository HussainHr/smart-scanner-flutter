import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';

class BarcodeDetection {
  const BarcodeDetection({
    required this.value,
    required this.type,
  });

  final String value;
  final ScanType type;
}
