import 'package:smart_scanner/features/scanner/data/datasources/barcode_scanner_datasource.dart';
import 'package:smart_scanner/features/scanner/domain/entities/barcode_detection.dart';
import 'package:smart_scanner/features/scanner/domain/repositories/scanner_repository.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  ScannerRepositoryImpl({
    required BarcodeScannerDatasource barcodeScannerDatasource,
  }) : _barcodeScannerDatasource = barcodeScannerDatasource;

  final BarcodeScannerDatasource _barcodeScannerDatasource;

  BarcodeScannerDatasource get barcodeScannerDatasource =>
      _barcodeScannerDatasource;

  @override
  BarcodeDetection? peekPendingDetection() {
    return _barcodeScannerDatasource.getLatestDetection();
  }
}
