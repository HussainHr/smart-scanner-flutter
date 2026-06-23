import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';

enum AddScanResult {
  added,
  quantityIncreased,
}

class InspectionListNotifier extends Notifier<List<ScanItem>> {
  static const int _maxQuantity = 9999;

  @override
  List<ScanItem> build() => [];

  AddScanResult addScan(ScanItem item) {
    final existingIndex =
        state.indexWhere((existing) => existing.value == item.value);

    if (existingIndex != -1) {
      final existing = state[existingIndex];
      final updatedQuantity =
          (existing.quantity + item.quantity).clamp(1, _maxQuantity);

      state = [
        for (var index = 0; index < state.length; index++)
          if (index == existingIndex)
            existing.copyWith(quantity: updatedQuantity)
          else
            state[index],
      ];

      return AddScanResult.quantityIncreased;
    }

    state = [...state, item];
    return AddScanResult.added;
  }

  void removeScan(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void updateQuantity(String id, int quantity) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(quantity: quantity) else item,
    ];
  }

  void updateCode(String id, String code) {
    final normalized = code.trim();
    if (normalized.isEmpty) {
      return;
    }

    final isDuplicate = state.any(
      (item) => item.id != id && item.value == normalized,
    );
    if (isDuplicate) {
      return;
    }

    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(value: normalized) else item,
    ];
  }

  void clear() {
    state = [];
  }
}

final inspectionListProvider =
    NotifierProvider<InspectionListNotifier, List<ScanItem>>(
  InspectionListNotifier.new,
);

class ScanQuantityNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void setQuantity(int quantity) {
    state = quantity.clamp(1, 9999);
  }

  void reset() {
    state = 1;
  }
}

final scanQuantityProvider = NotifierProvider<ScanQuantityNotifier, int>(
  ScanQuantityNotifier.new,
);

class LastScannedCodeNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setCode(String? code) {
    state = code;
  }

  void clear() {
    state = null;
  }
}

final lastScannedCodeProvider = NotifierProvider<LastScannedCodeNotifier, String?>(
  LastScannedCodeNotifier.new,
);
