import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';

enum AddScanResult {
  added,
  duplicate,
}

class InspectionListNotifier extends Notifier<List<ScanItem>> {
  @override
  List<ScanItem> build() => [];

  AddScanResult addScan(ScanItem item) {
    final isDuplicate = state.any((existing) => existing.value == item.value);
    if (isDuplicate) {
      return AddScanResult.duplicate;
    }

    state = [...state, item];
    return AddScanResult.added;
  }

  void clear() {
    state = [];
  }
}

final inspectionListProvider =
    NotifierProvider<InspectionListNotifier, List<ScanItem>>(
  InspectionListNotifier.new,
);
