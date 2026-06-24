import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/scanner/data/datasources/barcode_scanner_datasource.dart';
import 'package:smart_scanner/features/scanner/data/datasources/ocr_datasource.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/inspection_list_notifier.dart';

final barcodeScannerDatasourceProvider =
    Provider.autoDispose<BarcodeScannerDatasource>((ref) {
  final datasource = BarcodeScannerDatasource(
    onDetectionUpdated: (detection) {
      ref.read(pendingBarcodeProvider.notifier).setValue(detection.value);
    },
  );
  ref.onDispose(datasource.release);
  return datasource;
});

final ocrDatasourceProvider = Provider.autoDispose<OcrDatasource>((ref) {
  final datasource = OcrDatasource();
  ref.onDispose(datasource.dispose);
  return datasource;
});
