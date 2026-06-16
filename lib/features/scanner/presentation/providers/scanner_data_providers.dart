import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/scanner/data/datasources/barcode_scanner_datasource.dart';
import 'package:smart_scanner/features/scanner/data/datasources/ocr_datasource.dart';

final barcodeScannerDatasourceProvider =
    Provider.autoDispose<BarcodeScannerDatasource>((ref) {
  final datasource = BarcodeScannerDatasource();
  ref.onDispose(datasource.release);
  return datasource;
});

final ocrDatasourceProvider = Provider.autoDispose<OcrDatasource>((ref) {
  final datasource = OcrDatasource();
  ref.onDispose(datasource.dispose);
  return datasource;
});
