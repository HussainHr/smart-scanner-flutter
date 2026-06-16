import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';
import 'package:smart_scanner/features/scanner/presentation/providers/inspection_list_notifier.dart';

void main() {
  group('InspectionListNotifier', () {
    test('adds unique scans to the list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(inspectionListProvider.notifier);
      final item = ScanItem(
        id: '1',
        value: '1234567890',
        type: ScanType.barcode,
        scannedAt: DateTime(2026, 6, 16, 10, 30),
      );

      final result = notifier.addScan(item);

      expect(result, AddScanResult.added);
      expect(container.read(inspectionListProvider), [item]);
    });

    test('returns duplicate when value already exists', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(inspectionListProvider.notifier);
      final item = ScanItem(
        id: '1',
        value: 'QR-DUPLICATE',
        type: ScanType.qr,
        scannedAt: DateTime(2026, 6, 16, 10, 30),
      );

      notifier.addScan(item);
      final result = notifier.addScan(
        item.copyWith(id: '2', scannedAt: DateTime(2026, 6, 16, 10, 31)),
      );

      expect(result, AddScanResult.duplicate);
      expect(container.read(inspectionListProvider).length, 1);
    });

    test('clear removes all items', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(inspectionListProvider.notifier);
      notifier.addScan(
        ScanItem(
          id: '1',
          value: 'ABC',
          type: ScanType.barcode,
          scannedAt: DateTime.now(),
        ),
      );

      notifier.clear();

      expect(container.read(inspectionListProvider), isEmpty);
    });
  });
}
