import 'package:flutter_test/flutter_test.dart';
import 'package:smart_scanner/features/file_list/data/mappers/csv_preview_mapper.dart';

void main() {
  group('CsvPreviewMapper', () {
    test('parses csv rows into string cells', () {
      const content =
          '#,Type,Value,Scanned At\n1,Barcode,"ABC,123",2026-06-16 14:30:45\n2,QR Code,QR-VALUE,2026-06-16 14:31:10';

      final rows = CsvPreviewMapper.parseRows(content);

      expect(rows.length, 3);
      expect(rows.first, ['#', 'Type', 'Value', 'Scanned At']);
      expect(rows[1][2], 'ABC,123');
      expect(rows[2][1], 'QR Code');
    });

    test('returns empty list for blank content', () {
      expect(CsvPreviewMapper.parseRows('   '), isEmpty);
    });
  });
}
