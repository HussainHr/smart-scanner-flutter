import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/scanner/data/repositories/scanner_repository_impl.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_mode.dart';
import 'package:smart_scanner/features/scanner/domain/repositories/scanner_repository.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/scanner_data_providers.dart';

export 'scanner_data_providers.dart';

final scannerRepositoryProvider =
    Provider.autoDispose<ScannerRepository>((ref) {
  ref.watch(barcodeScannerDatasourceProvider);
  ref.watch(ocrDatasourceProvider);
  return ScannerRepositoryImpl(ref);
});

class ScanModeNotifier extends Notifier<ScanMode> {
  @override
  ScanMode build() => ScanMode.barcodeQr;

  void setMode(ScanMode mode) {
    if (state == mode) {
      return;
    }

    state = mode;
  }
}

final scanModeProvider = NotifierProvider<ScanModeNotifier, ScanMode>(
  ScanModeNotifier.new,
);

class ScanProcessingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setProcessing(bool isProcessing) {
    state = isProcessing;
  }
}

final scanProcessingProvider = NotifierProvider<ScanProcessingNotifier, bool>(
  ScanProcessingNotifier.new,
);
