import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scanner/features/save/data/mappers/inspection_csv_mapper.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_item.dart';
import 'package:smart_scanner/features/scanner/domain/entities/scan_type.dart';

void main() {
  group('InspectionCsvMapper', () {
    test('builds CSV with code and quantity columns', () {
      final items = [
        ScanItem(
          id: '1',
          value: 'ABC,123',
          type: ScanType.barcode,
          scannedAt: DateTime(2026, 6, 16, 14, 30, 45),
          quantity: 2,
        ),
        ScanItem(
          id: '2',
          value: 'QR-VALUE',
          type: ScanType.qr,
          scannedAt: DateTime(2026, 6, 16, 14, 31, 10),
          quantity: 1,
        ),
      ];

      final csv = InspectionCsvMapper.toCsv(items);

      expect(csv, contains('#,Code,Quantity,Type,Scanned At'));
      expect(csv, contains('"ABC,123"'));
      expect(csv, contains('QR Code'));
      expect(csv, contains(',2,'));
    });
  });

  group('InspectionFileNameBuilder', () {
    test('builds inspection spreadsheet filename with timestamp', () {
      final fileName = InspectionFileNameBuilder.build();

      expect(fileName, startsWith('inspection_'));
      expect(fileName, endsWith('.xlsx'));
    });
  });
}
