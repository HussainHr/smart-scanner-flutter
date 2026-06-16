import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/scanner/data/datasources/barcode_scanner_datasource.dart';
import 'package:smart_scanner/features/scanner/data/repositories/scanner_repository_impl.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_mode.dart';
import 'package:smart_scanner/features/scanner/domain/repositories/scanner_repository.dart';

final barcodeScannerDatasourceProvider =
    Provider<BarcodeScannerDatasource>((ref) {
  final datasource = BarcodeScannerDatasource();
  ref.onDispose(datasource.dispose);
  return datasource;
});

final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  return ScannerRepositoryImpl(
    barcodeScannerDatasource: ref.watch(barcodeScannerDatasourceProvider),
  );
});

final scannerRepositoryImplProvider = Provider<ScannerRepositoryImpl>((ref) {
  return ref.watch(scannerRepositoryProvider) as ScannerRepositoryImpl;
});

class ScanModeNotifier extends Notifier<ScanMode> {
  @override
  ScanMode build() => ScanMode.barcodeQr;
}

final scanModeProvider = NotifierProvider<ScanModeNotifier, ScanMode>(
  ScanModeNotifier.new,
);
